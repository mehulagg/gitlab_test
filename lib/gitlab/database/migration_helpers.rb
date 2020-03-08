# frozen_string_literal: true

require "gitlab/migration_helpers"

module Gitlab
  module Database
    module MigrationHelpers
      include Gitlab::MigrationHelpers

      BACKGROUND_MIGRATION_BATCH_SIZE = 1000 # Number of rows to process per job
      BACKGROUND_MIGRATION_JOB_BUFFER_SIZE = 1000 # Number of jobs to bulk queue at a time

      # Executes the block with a retry mechanism that alters the +lock_timeout+ and +sleep_time+ between attempts.
      # The timings can be controlled via the +timing_configuration+ parameter.
      # If the lock was not acquired within the retry period, a last attempt is made without using +lock_timeout+.
      #
      # ==== Examples
      #   # Invoking without parameters
      #   with_lock_retries do
      #     drop_table :my_table
      #   end
      #
      #   # Invoking with custom +timing_configuration+
      #   t = [
      #     [1.second, 1.second],
      #     [2.seconds, 2.seconds]
      #   ]
      #
      #   with_lock_retries(timing_configuration: t) do
      #     drop_table :my_table # this will be retried twice
      #   end
      #
      #   # Disabling the retries using an environment variable
      #   > export DISABLE_LOCK_RETRIES=true
      #
      #   with_lock_retries do
      #     drop_table :my_table # one invocation, it will not retry at all
      #   end
      #
      # ==== Parameters
      # * +timing_configuration+ - [[ActiveSupport::Duration, ActiveSupport::Duration], ...] lock timeout for the block, sleep time before the next iteration, defaults to `Gitlab::Database::WithLockRetries::DEFAULT_TIMING_CONFIGURATION`
      # * +logger+ - [Gitlab::JsonLogger]
      # * +env+ - [Hash] custom environment hash, see the example with `DISABLE_LOCK_RETRIES`
      def with_lock_retries(**args, &block)
        merged_args = {
          klass: self.class,
          logger: Gitlab::BackgroundMigration::Logger
        }.merge(args)

        Gitlab::Database::WithLockRetries.new(merged_args).run(&block)
      end

      def true_value
        Database.true_value
      end

      def false_value
        Database.false_value
      end

      # Reverses operations performed by rename_column_concurrently.
      #
      # This method takes care of removing previously installed triggers as well
      # as removing the new column.
      #
      # table - The name of the database table.
      # old - The name of the old column.
      # new - The name of the new column.
      def undo_rename_column_concurrently(table, old, new)
        trigger_name = rename_trigger_name(table, old, new)

        check_trigger_permissions!(table)

        remove_rename_triggers_for_postgresql(table, trigger_name)

        remove_column(table, new)
      end

      # Changes the type of a column concurrently.
      #
      # table - The table containing the column.
      # column - The name of the column to change.
      # new_type - The new column type.
      def change_column_type_concurrently(table, column, new_type)
        temp_column = "#{column}_for_type_change"

        rename_column_concurrently(table, column, temp_column, type: new_type)
      end

      # Performs cleanup of a concurrent type change.
      #
      # table - The table containing the column.
      # column - The name of the column to change.
      # new_type - The new column type.
      def cleanup_concurrent_column_type_change(table, column)
        temp_column = "#{column}_for_type_change"

        transaction do
          # This has to be performed in a transaction as otherwise we might have
          # inconsistent data.
          cleanup_concurrent_column_rename(table, column, temp_column)
          rename_column(table, temp_column, column)
        end
      end

      # Cleans up a concurrent column name.
      #
      # This method takes care of removing previously installed triggers as well
      # as removing the old column.
      #
      # table - The name of the database table.
      # old - The name of the old column.
      # new - The name of the new column.
      def cleanup_concurrent_column_rename(table, old, new)
        trigger_name = rename_trigger_name(table, old, new)

        check_trigger_permissions!(table)

        remove_rename_triggers_for_postgresql(table, trigger_name)

        remove_column(table, old)
      end

      # Reverses the operations performed by cleanup_concurrent_column_rename.
      #
      # This method adds back the old_column removed
      # by cleanup_concurrent_column_rename.
      # It also adds back the (old_column > new_column) trigger that is removed
      # by cleanup_concurrent_column_rename.
      #
      # table - The name of the database table containing the column.
      # old - The old column name.
      # new - The new column name.
      # type - The type of the old column. If no type is given the new column's
      #        type is used.
      def undo_cleanup_concurrent_column_rename(table, old, new, type: nil)
        if transaction_open?
          raise 'undo_cleanup_concurrent_column_rename can not be run inside a transaction'
        end

        check_trigger_permissions!(table)

        create_column_from(table, new, old, type: type)

        install_rename_triggers(table, old, new)
      end

      # Changes the column type of a table using a background migration.
      #
      # Because this method uses a background migration it's more suitable for
      # large tables. For small tables it's better to use
      # `change_column_type_concurrently` since it can complete its work in a
      # much shorter amount of time and doesn't rely on Sidekiq.
      #
      # Example usage:
      #
      #     class Issue < ActiveRecord::Base
      #       self.table_name = 'issues'
      #
      #       include EachBatch
      #
      #       def self.to_migrate
      #         where('closed_at IS NOT NULL')
      #       end
      #     end
      #
      #     change_column_type_using_background_migration(
      #       Issue.to_migrate,
      #       :closed_at,
      #       :datetime_with_timezone
      #     )
      #
      # Reverting a migration like this is done exactly the same way, just with
      # a different type to migrate to (e.g. `:datetime` in the above example).
      #
      # relation - An ActiveRecord relation to use for scheduling jobs and
      #            figuring out what table we're modifying. This relation _must_
      #            have the EachBatch module included.
      #
      # column - The name of the column for which the type will be changed.
      #
      # new_type - The new type of the column.
      #
      # batch_size - The number of rows to schedule in a single background
      #              migration.
      #
      # interval - The time interval between every background migration.
      def change_column_type_using_background_migration(
        relation,
        column,
        new_type,
        batch_size: 10_000,
        interval: 10.minutes
      )

        unless relation.model < EachBatch
          raise TypeError, 'The relation must include the EachBatch module'
        end

        temp_column = "#{column}_for_type_change"
        table = relation.table_name
        max_index = 0

        add_column(table, temp_column, new_type)
        install_rename_triggers(table, column, temp_column)

        # Schedule the jobs that will copy the data from the old column to the
        # new one. Rows with NULL values in our source column are skipped since
        # the target column is already NULL at this point.
        relation.where.not(column => nil).each_batch(of: batch_size) do |batch, index|
          start_id, end_id = batch.pluck('MIN(id), MAX(id)').first
          max_index = index

          migrate_in(
            index * interval,
            'CopyColumn',
            [table, column, temp_column, start_id, end_id]
          )
        end

        # Schedule the renaming of the column to happen (initially) 1 hour after
        # the last batch finished.
        migrate_in(
          (max_index * interval) + 1.hour,
          'CleanupConcurrentTypeChange',
          [table, column, temp_column]
        )

        if perform_background_migration_inline?
          # To ensure the schema is up to date immediately we perform the
          # migration inline in dev / test environments.
          Gitlab::BackgroundMigration.steal('CopyColumn')
          Gitlab::BackgroundMigration.steal('CleanupConcurrentTypeChange')
        end
      end

      # Renames a column using a background migration.
      #
      # Because this method uses a background migration it's more suitable for
      # large tables. For small tables it's better to use
      # `rename_column_concurrently` since it can complete its work in a much
      # shorter amount of time and doesn't rely on Sidekiq.
      #
      # Example usage:
      #
      #     rename_column_using_background_migration(
      #       :users,
      #       :feed_token,
      #       :rss_token
      #     )
      #
      # table - The name of the database table containing the column.
      #
      # old - The old column name.
      #
      # new - The new column name.
      #
      # type - The type of the new column. If no type is given the old column's
      #        type is used.
      #
      # batch_size - The number of rows to schedule in a single background
      #              migration.
      #
      # interval - The time interval between every background migration.
      def rename_column_using_background_migration(
        table,
        old_column,
        new_column,
        type: nil,
        batch_size: 10_000,
        interval: 10.minutes
      )

        check_trigger_permissions!(table)

        old_col = column_for(table, old_column)
        new_type = type || old_col.type
        max_index = 0

        add_column(table, new_column, new_type,
                   limit: old_col.limit,
                   precision: old_col.precision,
                   scale: old_col.scale)

        # We set the default value _after_ adding the column so we don't end up
        # updating any existing data with the default value. This isn't
        # necessary since we copy over old values further down.
        change_column_default(table, new_column, old_col.default) if old_col.default

        install_rename_triggers(table, old_column, new_column)

        model = Class.new(ActiveRecord::Base) do
          self.table_name = table

          include ::EachBatch
        end

        # Schedule the jobs that will copy the data from the old column to the
        # new one. Rows with NULL values in our source column are skipped since
        # the target column is already NULL at this point.
        model.where.not(old_column => nil).each_batch(of: batch_size) do |batch, index|
          start_id, end_id = batch.pluck('MIN(id), MAX(id)').first
          max_index = index

          migrate_in(
            index * interval,
            'CopyColumn',
            [table, old_column, new_column, start_id, end_id]
          )
        end

        # Schedule the renaming of the column to happen (initially) 1 hour after
        # the last batch finished.
        migrate_in(
          (max_index * interval) + 1.hour,
          'CleanupConcurrentRename',
          [table, old_column, new_column]
        )

        if perform_background_migration_inline?
          # To ensure the schema is up to date immediately we perform the
          # migration inline in dev / test environments.
          Gitlab::BackgroundMigration.steal('CopyColumn')
          Gitlab::BackgroundMigration.steal('CleanupConcurrentRename')
        end
      end

      def perform_background_migration_inline?
        Rails.env.test? || Rails.env.development?
      end

      # Removes the triggers used for renaming a PostgreSQL column concurrently.
      def remove_rename_triggers_for_postgresql(table, trigger)
        execute("DROP TRIGGER IF EXISTS #{trigger} ON #{table}")
        execute("DROP FUNCTION IF EXISTS #{trigger}()")
      end

      def remove_foreign_key_if_exists(*args)
        if foreign_key_exists?(*args)
          remove_foreign_key(*args)
        end
      end

      def remove_foreign_key_without_error(*args)
        remove_foreign_key(*args)
      rescue ArgumentError
      end

      def sidekiq_queue_migrate(queue_from, to:)
        while sidekiq_queue_length(queue_from) > 0
          Sidekiq.redis do |conn|
            conn.rpoplpush "queue:#{queue_from}", "queue:#{to}"
          end
        end
      end

      def sidekiq_queue_length(queue_name)
        Sidekiq.redis do |conn|
          conn.llen("queue:#{queue_name}")
        end
      end

      # Bulk queues background migration jobs for an entire table, batched by ID range.
      # "Bulk" meaning many jobs will be pushed at a time for efficiency.
      # If you need a delay interval per job, then use `queue_background_migration_jobs_by_range_at_intervals`.
      #
      # model_class - The table being iterated over
      # job_class_name - The background migration job class as a string
      # batch_size - The maximum number of rows per job
      #
      # Example:
      #
      #     class Route < ActiveRecord::Base
      #       include EachBatch
      #       self.table_name = 'routes'
      #     end
      #
      #     bulk_queue_background_migration_jobs_by_range(Route, 'ProcessRoutes')
      #
      # Where the model_class includes EachBatch, and the background migration exists:
      #
      #     class Gitlab::BackgroundMigration::ProcessRoutes
      #       def perform(start_id, end_id)
      #         # do something
      #       end
      #     end
      def bulk_queue_background_migration_jobs_by_range(model_class, job_class_name, batch_size: BACKGROUND_MIGRATION_BATCH_SIZE)
        raise "#{model_class} does not have an ID to use for batch ranges" unless model_class.column_names.include?('id')

        jobs = []
        table_name = model_class.quoted_table_name

        model_class.each_batch(of: batch_size) do |relation|
          start_id, end_id = relation.pluck("MIN(#{table_name}.id)", "MAX(#{table_name}.id)").first

          if jobs.length >= BACKGROUND_MIGRATION_JOB_BUFFER_SIZE
            # Note: This code path generally only helps with many millions of rows
            # We push multiple jobs at a time to reduce the time spent in
            # Sidekiq/Redis operations. We're using this buffer based approach so we
            # don't need to run additional queries for every range.
            bulk_migrate_async(jobs)
            jobs.clear
          end

          jobs << [job_class_name, [start_id, end_id]]
        end

        bulk_migrate_async(jobs) unless jobs.empty?
      end

      # Queues background migration jobs for an entire table, batched by ID range.
      # Each job is scheduled with a `delay_interval` in between.
      # If you use a small interval, then some jobs may run at the same time.
      #
      # model_class - The table or relation being iterated over
      # job_class_name - The background migration job class as a string
      # delay_interval - The duration between each job's scheduled time (must respond to `to_f`)
      # batch_size - The maximum number of rows per job
      # other_arguments - Other arguments to send to the job
      #
      # Example:
      #
      #     class Route < ActiveRecord::Base
      #       include EachBatch
      #       self.table_name = 'routes'
      #     end
      #
      #     queue_background_migration_jobs_by_range_at_intervals(Route, 'ProcessRoutes', 1.minute)
      #
      # Where the model_class includes EachBatch, and the background migration exists:
      #
      #     class Gitlab::BackgroundMigration::ProcessRoutes
      #       def perform(start_id, end_id)
      #         # do something
      #       end
      #     end
      def queue_background_migration_jobs_by_range_at_intervals(model_class, job_class_name, delay_interval, batch_size: BACKGROUND_MIGRATION_BATCH_SIZE, other_arguments: [])
        raise "#{model_class} does not have an ID to use for batch ranges" unless model_class.column_names.include?('id')

        # To not overload the worker too much we enforce a minimum interval both
        # when scheduling and performing jobs.
        if delay_interval < BackgroundMigrationWorker.minimum_interval
          delay_interval = BackgroundMigrationWorker.minimum_interval
        end

        model_class.each_batch(of: batch_size) do |relation, index|
          start_id, end_id = relation.pluck(Arel.sql('MIN(id), MAX(id)')).first

          # `BackgroundMigrationWorker.bulk_perform_in` schedules all jobs for
          # the same time, which is not helpful in most cases where we wish to
          # spread the work over time.
          migrate_in(delay_interval * index, job_class_name, [start_id, end_id] + other_arguments)
        end
      end

      # Fetches indexes on a column by name for postgres.
      #
      # This will include indexes using an expression on the column, for example:
      # `CREATE INDEX CONCURRENTLY index_name ON table (LOWER(column));`
      #
      # We can remove this when upgrading to Rails 5 with an updated `index_exists?`:
      # - https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882
      #
      # Or this can be removed when we no longer support postgres < 9.5, so we
      # can use `CREATE INDEX IF NOT EXISTS`.
      def index_exists_by_name?(table, index)
        # We can't fall back to the normal `index_exists?` method because that
        # does not find indexes without passing a column name.
        if indexes(table).map(&:name).include?(index.to_s)
          true
        else
          postgres_exists_by_name?(table, index)
        end
      end

      def postgres_exists_by_name?(table, name)
        index_sql = <<~SQL
          SELECT COUNT(*)
          FROM pg_index
          JOIN pg_class i ON (indexrelid=i.oid)
          JOIN pg_class t ON (indrelid=t.oid)
          WHERE i.relname = '#{name}' AND t.relname = '#{table}'
        SQL

        connection.select_value(index_sql).to_i > 0
      end

      def create_or_update_plan_limit(limit_name, plan_name, limit_value)
        execute <<~SQL
          INSERT INTO plan_limits (plan_id, #{quote_column_name(limit_name)})
          VALUES
            ((SELECT id FROM plans WHERE name = #{quote(plan_name)} LIMIT 1), #{quote(limit_value)})
          ON CONFLICT (plan_id) DO UPDATE SET #{quote_column_name(limit_name)} = EXCLUDED.#{quote_column_name(limit_name)};
        SQL
      end

      # Note this should only be used with very small tables
      def backfill_iids(table)
        sql = <<-END
          UPDATE #{table}
          SET iid = #{table}_with_calculated_iid.iid_num
          FROM (
            SELECT id, ROW_NUMBER() OVER (PARTITION BY project_id ORDER BY id ASC) AS iid_num FROM #{table}
          ) AS #{table}_with_calculated_iid
          WHERE #{table}.id = #{table}_with_calculated_iid.id
        END

        execute(sql)
      end

      def migrate_async(*args)
        with_migration_context do
          BackgroundMigrationWorker.perform_async(*args)
        end
      end

      def migrate_in(*args)
        with_migration_context do
          BackgroundMigrationWorker.perform_in(*args)
        end
      end

      def bulk_migrate_in(*args)
        with_migration_context do
          BackgroundMigrationWorker.bulk_perform_in(*args)
        end
      end

      def bulk_migrate_async(*args)
        with_migration_context do
          BackgroundMigrationWorker.bulk_perform_async(*args)
        end
      end

      def with_migration_context(&block)
        Gitlab::ApplicationContext.with_context(caller_id: self.class.to_s, &block)
      end
    end
  end
end
