class SetRunnerTypeNotNull < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    change_column_null(:ci_runners, :runner_type, false) # rubocop:disable Migration/PostMigrationMethods
  end
end
