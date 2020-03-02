module Gitlab
  module Database
    module PartitionAwareInstrumentation

      def self.included(instrumented_class)
        instrumented_class.class_eval do
          unless instrumented_class.method_defined?(:log_without_partition_warning)
            alias_method :log_without_partition_warning, :log
            alias_method :log, :log_with_partition_warning

            protected :log
          end
        end
      end

      def log_with_partition_warning(*args, &block)
        original_log_result = log_without_partition_warning(*args, &block)

        sql, _ = *args

        partitioned_models.each do |table, definition|
          if sql =~ definition[:table_regex] && sql !~ definition[:column_regex]
            message = "Query of \"%s\" does not include partition column \"%s\": %s originating from \n  %s"
            Rails.logger.warn(message % [table, definition[:column_name], sql, Kernel.caller.join("\n  ")])
          end
        end

        original_log_result
      end

      private

      def partitioned_models
        @partition_models ||= Hash[build_partitioned_models]
      end

      def build_partitioned_models
        partitioned_model_info.map do |table, column|
          [table, { table_regex: /SELECT.*FROM\s+"*#{table}*"/, column_name: column, column_regex: /#{column}/ }]
        end
      end

      def partitioned_model_info
        {
          "issues" => "namespace_id"
        }
      end
    end
  end
end
