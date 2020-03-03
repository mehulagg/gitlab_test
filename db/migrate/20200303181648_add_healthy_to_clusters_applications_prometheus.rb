# frozen_string_literal: true

class AddHealthyToClustersApplicationsPrometheus < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false
  disable_ddl_transaction!

  def up
    add_column_with_default :clusters_applications_prometheus, :healthy, :boolean, default: true
    add_column_with_default :clusters_applications_prometheus, :ready, :boolean, default: true
  end

  def down
    remove_column :clusters_applications_prometheus, :healthy
    remove_column :clusters_applications_prometheus, :ready
  end
end
