# frozen_string_literal: true

module Gitlab
  module Database
    module Reindexing
      class Index
        delegate :definition, :schema, :name, to: :@attrs, allow_nil: true

        def initialize(index_name)
          @attrs = find_index(index_name)
        end

        def exists?
          !@attrs.nil?
        end

        def unique?
          @attrs&.is_unique
        end

        def valid?
          @attrs&.is_valid
        end

        def to_s
          name
        end

        private

        def find_index(index_name)
          record = ActiveRecord::Base.connection.select_one(<<~SQL)
            SELECT
              pg_index.indisunique as is_unique,
              pg_index.indisvalid as is_valid,
              pg_indexes.indexdef as definition,
              pg_namespace.nspname as schema,
              pg_class.relname as name
            FROM pg_index
            INNER JOIN pg_class ON pg_class.oid = pg_index.indexrelid
            INNER JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
            INNER JOIN pg_indexes ON pg_class.relname = pg_indexes.indexname
            WHERE pg_namespace.nspname = 'public'
            AND pg_class.relname = #{ActiveRecord::Base.connection.quote(index_name)}
          SQL

          OpenStruct.new(record) if record
        end
      end
    end
  end
end
