# frozen_string_literal: true

module Gitlab
  module Database
    class IndexManager
      attr_reader :conn

      def initialize(conn = ActiveRecord::Base.connection)
        @conn = conn
      end

      def create(name, indexdef)
        conn.execute("CREATE INDEX CONCURRENTLY #{name} #{indexdef}")
      end

      def drop(name)
        conn.execute("DROP INDEX CONCURRENTLY IF EXISTS #{name}")
      end

      def swap_and_drop(from, to, tablename)
      end
    end

    class PgIndex < ActiveRecord::Base
      self.table_name = 'pg_indexes'

      def definition
        indexdef.gsub(/^CREATE( UNIQUE)? INDEX #{indexname} /, '')
      end
    end

    class Reindexer
      attr_reader :conn, :index_manager

      TEMP_INDEX = '_temp_index_for_reindexing'

      delegate :create, :drop, :swap_and_drop, to: :index_manager

      def initialize(conn: ActiveRecord::Base.connection, index_manager: IndexManager.new(conn))
        @conn = conn
        @index_manager = index_manager
      end

      def reindex(indexname)
        index = PgIndex.find_by(schemaname: 'public', indexname: indexname)

        tablename = index.tablename

        drop(TEMP_INDEX)
        create(TEMP_INDEX, index.definition)

        conn.transaction(requires_new: true) do
          # TODO: Retry with increasing lock timeout
          swap_and_drop(TEMP_INDEX, indexname, tablename)
        end

      ensure
        drop(TEMP_INDEX)
      end
    end
  end
end
