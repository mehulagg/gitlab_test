# frozen_string_literal: true

module Gitlab
  module Database
    module Reindexing
      class ConcurrentReindex
        include Gitlab::Utils::StrongMemoize
        include MigrationHelpers

        ReindexError = Class.new(StandardError)

        PG_IDENTIFIER_LENGTH = 63
        TEMPORARY_INDEX_PREFIX = 'tmp_reindex_'
        REPLACED_INDEX_PREFIX = 'old_reindex_'

        attr_reader :index, :logger

        def initialize(index, logger:)
          @index = index
          @logger = logger
        end

        def perform
          raise ReindexError, "index #{index} does not exist" unless index.exists?
          raise ReindexError, 'UNIQUE indexes are currently not supported' if index.unique?

          remove_replacement_index

          begin
            replacement_index = create_replacement_index

            unless replacement_index.valid?
              message = 'replacement index was created as INVALID'
              logger.error("#{message}, cleaning up")
              raise ReindexError, "failed to reindex #{index}: #{message}"
            end

            swap_replacement_index(replacement_index)
          rescue Gitlab::Database::WithLockRetries::AttemptsExhaustedError => e
            logger.error('failed to obtain the required database locks to swap the indexes, cleaning up')
            raise ReindexError, e.message
          rescue ActiveRecord::ActiveRecordError, PG::Error => e
            logger.error("database error while attempting reindex of #{index}: #{e.message}")
            raise ReindexError, e.message
          ensure
            logger.info("dropping unneeded replacement index: #{replacement_index_name}")
            remove_replacement_index
          end
        end

        private

        delegate :execute, to: :connection
        def connection
          @connection ||= ActiveRecord::Base.connection
        end

        def replacement_index_name
          @replacement_index_name ||= constrained_index_name(TEMPORARY_INDEX_PREFIX)
        end

        def constrained_index_name(prefix)
          "#{prefix}#{index.name}".slice(0, PG_IDENTIFIER_LENGTH)
        end

        def create_replacement_index
          create_replacement_index_statement = index.definition
            .sub(/CREATE INDEX/, 'CREATE INDEX CONCURRENTLY')
            .sub(/#{index.name}/, replacement_index_name)

          logger.info("creating replacement index #{replacement_index_name}")
          logger.debug("replacement index definition: #{create_replacement_index_statement}")

          disable_statement_timeout do
            connection.execute(create_replacement_index_statement)
          end

          Index.new(replacement_index_name)
        end

        def replacement_index_valid?
          find_index(replacement_index_name).indisvalid
        end

        def find_index(index_name)
          record = connection.select_one(<<~SQL)
            SELECT
              pg_index.indisunique,
              pg_index.indisvalid,
              pg_indexes.indexdef
            FROM pg_index
            INNER JOIN pg_class ON pg_class.oid = pg_index.indexrelid
            INNER JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
            INNER JOIN pg_indexes ON pg_class.relname = pg_indexes.indexname
            WHERE pg_namespace.nspname = 'public'
            AND pg_class.relname = #{connection.quote(index_name)}
          SQL

          OpenStruct.new(record) if record
        end

        def swap_replacement_index(replacement_index)
          replaced_index_name = constrained_index_name(REPLACED_INDEX_PREFIX)

          logger.info("swapping replacement index #{replacement_index} with #{index}")

          with_lock_retries do
            rename_index(index.name, replaced_index_name)
            rename_index(replacement_index.name, index.name)
            rename_index(replaced_index_name, replacement_index.name)
          end
        end

        def rename_index(old_index_name, new_index_name)
          connection.execute("ALTER INDEX #{old_index_name} RENAME TO #{new_index_name}")
        end

        def remove_replacement_index
          logger.debug("dropping dangling index from previous run: #{replacement_index_name}")

          disable_statement_timeout do
            connection.execute("DROP INDEX CONCURRENTLY IF EXISTS #{replacement_index_name}")
          end
        end

        def with_lock_retries(&block)
          arguments = { klass: self.class, logger: logger }

          Gitlab::Database::WithLockRetries.new(arguments).run(raise_on_exhaustion: true, &block)
        end
      end
    end
  end
end
