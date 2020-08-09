# frozen_string_literal: true

class DropApprovalRuleNameIndexForCodeOwnersIndex < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    remove_concurrent_index :approval_merge_request_rules, :approval_rule_name_index_for_code_owners
  end

  def down
    add_concurrent_index(
      :approval_merge_request_rules,
      [:merge_request_id, :code_owner, :name],
      unique: true,
      where: "code_owner = true AND section IS NULL",
      name: "approval_rule_name_index_for_code_owners"
    )
  end
end
