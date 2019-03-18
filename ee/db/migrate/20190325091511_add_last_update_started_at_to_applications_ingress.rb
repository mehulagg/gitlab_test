class AddLastUpdateStartedAtToApplicationsIngress < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  def change
    add_column :clusters_applications_ingress, :last_update_started_at, :datetime_with_timezone
  end
end
