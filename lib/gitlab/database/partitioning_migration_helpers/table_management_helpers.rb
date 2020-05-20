# frozen_string_literal: true

module Gitlab
  module Database
    module PartitioningMigrationHelpers
      module TableManagementHelpers
        include SchemaHelpers

        def partition_table_by_date(table_name, column_name, partitioned_table: nil, min_time:, max_time:)
          primary_key = connection.primary_key(table_name)
          raise "primary key not defined for #{table_name}" if primary_key.nil?

          column_def = find_column_definition(table_name, column_name)
          raise "partition column #{column_name} does not exist on #{table_name}" if column_def.nil?

          new_table_name = partitioned_table || partitioned_table_name(table_name)
          create_range_partitioned_copy(new_table_name, table_name, column_def, primary_key)
          create_range_partitions(new_table_name, column_def.name, min_time, max_time)
        end

        def drop_partitioned_table_for(table_name)
          drop_table(partitioned_table_name(table_name))
        end

        def partitioned_table_name(table, suffix: 'part')
          tmp_table_name("#{table}_#{suffix}")
        end

        private

        def find_column_definition(table, column)
          connection.columns(table).find { |c| c.name == column.to_s }
        end

        def create_range_partitioned_copy(table_name, template_table_name, partition_column, primary_key)
          tmp_column_name = object_name(partition_column.name, 'partition_key')

          execute(<<~SQL)
            CREATE TABLE #{table_name} (
              LIKE #{template_table_name} INCLUDING ALL EXCLUDING INDEXES,
              #{tmp_column_name} #{partition_column.sql_type} NOT NULL,
              PRIMARY KEY (#{[primary_key, tmp_column_name].join(", ")})
            ) PARTITION BY RANGE (#{tmp_column_name})
          SQL

          remove_column(table_name, partition_column.name)
          rename_column(table_name, tmp_column_name, partition_column.name)
          change_column_default(table_name, primary_key, nil)
        end

        def create_range_partitions(table_name, column_name, min_time, max_time, schema: 'partitions')
          min_date = min_time.beginning_of_month.to_date
          max_date = max_time.next_month.beginning_of_month.to_date

          while min_date < max_date
            partition_name = "#{table_name}_#{min_date.strftime('%Y%m')}"
            next_date = min_date.next_month
            lower_bound = min_date.strftime('%Y-%m-%d')
            upper_bound = next_date.strftime('%Y-%m-%d')

            execute(<<~SQL)
              CREATE TABLE #{schema}.#{partition_name} PARTITION OF #{table_name}
              FOR VALUES FROM ('#{lower_bound}') TO ('#{upper_bound}')
            SQL

            min_date = next_date
          end
        end
      end
    end
  end
end
