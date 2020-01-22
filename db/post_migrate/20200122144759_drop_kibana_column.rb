# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class DropKibanaColumn < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    remove_column :clusters_applications_elastic_stacks, :kibana_hostname, :string, limit: 255
  end
end
