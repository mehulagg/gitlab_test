# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIssuesPrometheusAlertEventJoinTable < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def change
    create_join_table :issues, :prometheus_alert_events, id: false do |t|
        t.index [:issue_id, :prometheus_alert_event_id], unique: true, name: 'issue_id_prometheus_alert_event_id_index'
        t.timestamps
    end
  end
end
