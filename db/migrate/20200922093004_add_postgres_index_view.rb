# frozen_string_literal: true

class AddPostgresIndexView < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    execute(<<~SQL)
      CREATE VIEW postgres_indexes AS
      SELECT
        pg_namespace.nspname || '.' || pg_class.relname as identifier,
        pg_namespace.nspname as schema,
        pg_class.relname as name,
        pg_index.indisunique as is_unique,
        pg_index.indisvalid as is_valid,
        pg_indexes.indexdef as definition
      FROM pg_index
      INNER JOIN pg_class ON pg_class.oid = pg_index.indexrelid
      INNER JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
      INNER JOIN pg_indexes ON pg_class.relname = pg_indexes.indexname
    SQL
  end

  def down
    execute(<<~SQL)
      DROP VIEW postgres_indexes
    SQL
  end
end
