# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddSprints < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def change
    create_table :sprints, id: :bigserial do |t|
      t.timestamps_with_timezone null: false
      t.date :start_date
      t.date :due_date

      t.integer :iid
      t.integer :cached_markdown_version
      t.references :project, foreign_key: { on_delete: :cascade }, index: false
      t.references :group, foreign_key: { to_table: :namespaces, on_delete: :cascade }, index: true
      t.string :title, null: false, limit: 255
      t.string :state, limit: 255
      t.text :title_html
      t.text :description
      t.text :description_html

      t.index ["description"], name: "index_sprints_on_description_trigram", opclass: :gin_trgm_ops, using: :gin
      t.index ["due_date"]
      t.index %w(project_id iid), unique: true
      t.index ["title"]
      t.index ["title"], name: "index_sprints_on_title_trigram", opclass: :gin_trgm_ops, using: :gin
    end
  end
end
