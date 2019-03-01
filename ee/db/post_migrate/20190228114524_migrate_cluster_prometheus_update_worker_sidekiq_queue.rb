# frozen_string_literal: true

class MigrateClusterPrometheusUpdateWorkerSidekiqQueue < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    sidekiq_queue_migrate 'gcp_cluster:cluster_update_app', to: 'gcp_cluster:cluster_prometheus_update'
  end

  def down
    sidekiq_queue_migrate 'gcp_cluster:cluster_prometheus_update', to: 'gcp_cluster:cluster_update_app'
  end
end
