# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    module SchemaCacheMixin
      # Indexes do not exist on Views
      # we need to get indexes from the table instead
      def indexes(table_name)
        if data_source_exists?(source_table_name(table_name))
          indexes(source_table_name(table_name))
        else
          super
        end
      end

      def source_table_name(table_name)
        "#{table_name}_column_rename"
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::SchemaCache.prepend(
  ActiveRecord::ConnectionAdapters::SchemaCacheMixin
)
