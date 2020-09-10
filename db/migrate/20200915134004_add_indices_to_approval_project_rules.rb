# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIndicesToApprovalProjectRules < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :approval_project_rules, :id, where: 'rule_type = 0', name: 'index_approval_project_rules_on_id_with_regular_type'
    add_concurrent_index :approval_project_rules_users, :approval_project_rule_id
  end

  def down
    remove_concurrent_index :approval_project_rules, :id
    remove_concurrent_index :approval_project_rules_users, :approval_project_rule_id
  end
end
