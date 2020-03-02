# frozen_string_literal: true

class AddConfiguringToServerlessDomainCluster < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :serverless_domain_cluster, :configuring, :boolean, default: false, null: false # rubocop:disable Migration/AddColumn
  end
end
