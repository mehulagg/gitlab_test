# frozen_string_literal: true

class MigrateOpsFeatureFlagsScopesTargetUserIds < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  class OperationsFeatureFlagScope < ActiveRecord::Base
  end

  def up
    scopes = OperationsFeatureFlagScope.all

    scopes.each do |scope|
      if scope.active == false

        userwithid_strategy = scope.strategies.find { |s| s['name'] == 'userWithId' }

        if userwithid_strategy.present?
          scope.update!({
            active: true,
            strategies: [userwithid_strategy]
          })
        end
      end

      if scope.active
        userwithid_strategy = scope.strategies.find { |s| s['name'] == 'userWithId' }
        default_strategy = scope.strategies.find { |s| s['name'] == 'default' }

        if userwithid_strategy.present? && default_strategy.present?
          scope.update!({
            active: true,
            strategies: [default_strategy]
          })
        end
      end
    end
  end

  def down
  end
end
