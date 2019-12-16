# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddExecutionMethodToCiBuilds < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  def change
    add_column :ci_builds_metadata, :execution_method, :int, limit: 2
  end
end
