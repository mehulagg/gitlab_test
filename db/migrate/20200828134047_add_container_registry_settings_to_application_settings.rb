# frozen_string_literal: true

class AddContainerRegistrySettingsToApplicationSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    add_column(:application_settings, :container_registry_expiration_policies_capacity, :integer, default: 100, null: false)
  end

  def down
    remove_column(:application_settings, :container_registry_expiration_policies_capacity)
  end
end
