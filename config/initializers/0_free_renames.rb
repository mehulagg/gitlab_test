# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    class Column
      attr_writer :name
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    module SchemaCacheMixin
      def primary_keys(table_name)
        if data_source_exists?(source_table_name(table_name))
          primary_keys(source_table_name(table_name))
        else
          super
        end
      end

      def columns(table_name)
        if data_source_exists?(source_table_name(table_name))
          columns(source_table_name(table_name)).tap do |columns|
            next unless columns

            columns.each do |column|
              new_name = column_renames.dig(table_name, column.name)
              column.name = new_name if new_name
            end
          end
        else
          super
        end
      end

      def indexes(table_name)
        if data_source_exists?(source_table_name(table_name))
          indexes(source_table_name(table_name))
        else
          super
        end
      end

      def clear_data_source_cache!(name)
        super(name)
        super(source_table_name(name))
      end

      def source_table_name(table_name)
        "#{table_name}_column_rename"
      end

      def column_renames
        # TODO: put it in a more suitable place
        {
          "ci_trigger_requests" => {
            "commit_id" => "pipeline_id"
          }
        }
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::SchemaCache.prepend(
  ActiveRecord::ConnectionAdapters::SchemaCacheMixin
)
