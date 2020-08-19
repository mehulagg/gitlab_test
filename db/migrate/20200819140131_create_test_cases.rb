# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateTestCases < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :quality_test_cases do |t|
      t.timestamps_with_timezone null: false
      t.references :project, null: false, foreign_key: { on_delete: :cascade }
      t.integer :cached_markdown_version
      t.integer :iid, null: false
      t.integer :state, limit: 2, default: 1, null: false
      t.string :title, limit: 255, null: false # rubocop:disable Migration/PreventStrings
      # rubocop:disable Migration/AddLimitToTextColumns
      t.text :title_html
      t.text :description
      t.text :description_html
      # rubocop:enable Migration/AddLimitToTextColumns
    end
  end
end
