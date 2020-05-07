# frozen_string_literal: true

class AddIntegrationsView < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  DOWNTIME = false

  def up
    # Should this be in a transaction?
    execute <<~SQL
      CREATE FUNCTION jsonb_merge_accum (jsonb, jsonb)
      RETURNS jsonb AS
      $$
      SELECT $1 || $2;
      $$ LANGUAGE 'sql' STRICT;

      CREATE AGGREGATE jsonb_merge(jsonb) ( INITCOND = '{}', STYPE = jsonb, SFUNC = jsonb_merge_accum );

      CREATE VIEW integrations
      AS
        WITH
        recursive recursive_services AS (
          SELECT *, integration_properties AS settings, 1 AS level FROM services_with_parent WHERE parent_id IS NULL
          UNION ALL
          SELECT services_with_parent.*, jsonb_merge_accum(recursive_services.integration_properties, services_with_parent.integration_properties) AS settings, level + 1 AS level FROM recursive_services JOIN services_with_parent ON recursive_services.id = services_with_parent.parent_id
        ),
        services_with_parent AS (
          SELECT services.id, services.project_id, services.integration_properties, regexp_replace(services.type, 'Service', 'Integration') as type, NULLIF(parent.id, services.id) AS parent_id FROM services JOIN services parent ON services.type = parent.type AND parent.instance IS TRUE
        )
      SELECT * FROM recursive_services;
    SQL
  end

  def down
    # Should this be in a transaction?
    execute <<~SQL
      DROP VIEW integrations CASCADE;
      DROP FUNCTION jsonb_merge_accum CASCADE;
    SQL
  end
end
