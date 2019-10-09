# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddCustomHttpCloneHostToApplicationSettings < ActiveRecord::Migration[5.2]
  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def change
    add_column :application_settings, :custom_http_clone_host, :string, limit: 255
  end
end
