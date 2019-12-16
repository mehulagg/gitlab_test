# frozen_string_literal: true

class AddSchemaVersionToPipelines < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  def change
    add_column :ci_pipelines, :schema_version, :int, limit: 16
  end
end
