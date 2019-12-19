# frozen_string_literal: true

class AddFkToGroupDeployTokens < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :group_deploy_tokens, :deploy_tokens, column: :deploy_token_id, on_delete: :cascade
    add_concurrent_foreign_key :group_deploy_tokens, :namespaces, column: :group_id, on_delete: :cascade
  end

  def down
    remove_foreign_key_if_exists :group_deploy_tokens, column: :deploy_token_id
    remove_foreign_key_if_exists :group_deploy_tokens, column: :group_id
  end
end
