# frozen_string_literal: true
class DropForkedProjectLinks < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    drop_table :forked_project_links
  end

  def down
    # no-op
  end
end
