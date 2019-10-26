# frozen_string_literal: true

module Gitlab
  module Geo
    class Fdw
      DEFAULT_SCHEMA = 'public'
      FOREIGN_SERVER = 'gitlab_secondary'
      FOREIGN_SCHEMA = 'gitlab_secondary'

      CACHE_KEYS = %i(
        geo_FOREIGN_SCHEMA_exist
        geo_foreign_schema_tables_match
        geo_fdw_count_tables
      ).freeze

      class << self
        # Return if FDW is enabled for this instance
        #
        # @return [Boolean] whether FDW is enabled
        def enabled?
          return false unless fdw_capable?

          # FDW is enabled by default, disable it by setting `fdw: false` in config/database_geo.yml
          value = Rails.configuration.geo_database['fdw']
          value.nil? ? true : value
        end

        def disabled?
          !enabled?
        end

        # Return full table name with foreign schema
        #
        # @param [String] table_name
        def foreign_table_name(table_name)
          FOREIGN_SCHEMA + ".#{table_name}"
        end

        def foreign_tables_up_to_date?(skip_cache: false)
          if skip_cache
            uncached_has_foreign_schema? && uncached_foreign_schema_tables_match?
          else
            has_foreign_schema? && foreign_schema_tables_match?
          end
        end

        # Number of existing tables
        #
        # @return [Integer] number of tables
        def foreign_schema_tables_count
          Gitlab::Geo.cache_value(:geo_fdw_count_tables) do
            sql = <<~SQL
              SELECT COUNT(*)
                FROM information_schema.foreign_tables
               WHERE foreign_table_schema = '#{FOREIGN_SCHEMA}'
                 AND foreign_table_name NOT LIKE 'pg_%'
            SQL

            ::Geo::TrackingBase.connection.execute(sql).first.fetch('count').to_i
          end
        end

        def gitlab_schema_tables_count
          ActiveRecord::Schema.tables.reject { |table| table.start_with?('pg_') }.count
        end

        def expire_cache!
          Gitlab::Geo.expire_cache_keys!(CACHE_KEYS)
        end

        private

        def fdw_capable?
          has_foreign_server? && has_foreign_schema? && foreign_schema_tables_count.positive?
        rescue ::Geo::TrackingBase::SecondaryNotConfigured
          false
        end

        # Check if there is at least one foreign server configured
        #
        # @return [Boolean] whether any foreign server exists
        def has_foreign_server?
          ::Geo::TrackingBase.connection.execute(
            "SELECT 1 FROM pg_foreign_server"
          ).count.positive?
        end

        def has_foreign_schema?
          Gitlab::Geo.cache_value(:geo_FOREIGN_SCHEMA_exist) do
            uncached_has_foreign_schema?
          end
        end

        def uncached_has_foreign_schema?
          sql = <<~SQL
            SELECT 1
              FROM information_schema.schemata
            WHERE schema_name='#{FOREIGN_SCHEMA}'
          SQL

          Gitlab::Geo::DatabaseTasks.with_geo_db do
            ActiveRecord::Base.connection.execute(sql).count.positive?
          end
        end

        # Check if foreign schema has exact the same tables and fields defined on secondary database
        #
        # @return [Boolean] whether schemas match and are not empty
        def foreign_schema_tables_match?
          Gitlab::Geo.cache_value(:geo_foreign_schema_tables_match) do
            uncached_foreign_schema_tables_match?
          end
        end

        def uncached_foreign_schema_tables_match?
          gitlab_schema_tables = retrieve_gitlab_schema_tables.to_set
          foreign_schema_tables = retrieve_foreign_schema_tables.to_set

          gitlab_schema_tables.present? && (gitlab_schema_tables == foreign_schema_tables)
        end

        def retrieve_foreign_schema_tables
          database_configs = Gitlab::Geo::DatabaseTasks.geo_settings[:database_config]
          env = ActiveRecord::Tasks::DatabaseTasks.env
          database = database_configs[env]['database']

          Gitlab::Geo::DatabaseTasks.with_geo_db do
            retrieve_schema_tables(database, FOREIGN_SCHEMA).to_a
          end
        end

        def retrieve_gitlab_schema_tables
          retrieve_schema_tables(ActiveRecord::Base.connection_config[:database], DEFAULT_SCHEMA).to_a
        end

        def retrieve_schema_tables(database, schema)
          sql = <<~SQL
              SELECT table_name, column_name, data_type
                FROM information_schema.columns
               WHERE table_catalog = '#{database}'
                 AND table_schema = '#{schema}'
                 AND table_name NOT LIKE 'pg_%'
            ORDER BY table_name, column_name, data_type
          SQL

          ActiveRecord::Base.connection.select_all(sql)
        end
      end
    end
  end
end
