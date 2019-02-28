# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

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
