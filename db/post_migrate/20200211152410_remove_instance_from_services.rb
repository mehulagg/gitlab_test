# frozen_string_literal: true

class RemoveInstanceFromServices < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    trigger_name = rename_trigger_name(:services, :template, :instance)
    remove_rename_triggers_for_postgresql(:services, trigger_name)

    return unless column_exists?(:services, :instance)

    remove_column :services, :instance
  end

  def down
    # This migration should not be rolled back because it
    # removes a column that got added in migrations that
    # have been reverted in https://gitlab.com/gitlab-org/gitlab/-/merge_requests/24857
  end
end
