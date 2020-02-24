# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddProjectSubscriptionsToPlanLimits < ActiveRecord::Migration[6.0]
  # Uncomment the following include if you require helper functions:
  # include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  # To disable transactions uncomment the following line and remove these
  # comments:
  # disable_ddl_transaction!

  def change
    add_column(:plan_limits, :ci_project_subscriptions, :integer, default: 0, null: false)
  end
end
