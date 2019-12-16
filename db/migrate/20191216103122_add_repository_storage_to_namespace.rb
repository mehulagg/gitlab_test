# frozen_string_literal: true

class AddRepositoryStorageToNamespace < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless column_exists?(:namespaces, :repository_storage)
      add_column_with_default(
        :namespaces,
        :repository_storage,
        :string,
        default: 'default',
        limit: 255,
        allow_null: false
      )
    end
  end

  def down
    if column_exists?(:namespaces, :repository_storage)
      remove_column(:namespaces, :repository_storage)
    end
  end
end
