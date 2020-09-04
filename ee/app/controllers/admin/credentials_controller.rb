# frozen_string_literal: true

class Admin::CredentialsController < Admin::ApplicationController
  extend ::Gitlab::Utils::Override
  include CredentialsInventoryActions
  include Analytics::UniqueVisitsHelper

  helper_method :credentials_inventory_path, :user_detail_path, :ssh_key_delete_path

  before_action :check_license_credentials_inventory_available!, only: [:index, :destroy]

  track_unique_visits :index, target_id: 'i_compliance_credential_inventory'

  private

  def check_license_credentials_inventory_available!
    render_404 unless credentials_inventory_feature_available?
  end

  override :delete_ssh_button_available
  def delete_ssh_button_available?
    true
  end

  override :credentials_inventory_path
  def credentials_inventory_path(args)
    admin_credentials_path(args)
  end

  override :user_detail_path
  def user_detail_path(user)
    admin_user_path(user)
  end

  override :ssh_key_delete_path
  def ssh_key_delete_path(key)
    delete_admin_credential_path(key)
  end

  override :users
  def users
    nil
  end
end
