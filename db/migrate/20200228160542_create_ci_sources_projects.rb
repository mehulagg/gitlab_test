# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateCiSourcesProjects < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  # To disable transactions uncomment the following line and remove these
  # comments:
  # disable_ddl_transaction!

  def change
    create_table :ci_sources_projects do |t|
      t.references :pipeline, null: false, foreign_key: { to_table: :ci_pipelines, on_delete: :cascade }
      t.references :source_project, null: false, foreign_key: { to_table: :projects, on_delete: :cascade }
    end
  end
end
