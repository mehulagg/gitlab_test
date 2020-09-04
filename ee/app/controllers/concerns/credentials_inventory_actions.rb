# frozen_string_literal: true

module CredentialsInventoryActions
  extend ActiveSupport::Concern
  include CredentialsInventoryHelper

  def index
    @credentials = filter_credentials.page(params[:page]).preload_users.without_count # rubocop:disable Gitlab/ModuleWithInstanceVariables

    respond_to do |format|
      format.html do
        render 'shared/credentials_inventory/index'
      end
    end
  end

  def destroy
    key = KeysFinder.new({ users: users, key_type: 'ssh' }).find_by_id(params[:id])
    Keys::DestroyService.new(current_user).execute(key)

    respond_to do |format|
      format.html { redirect_to credentials_inventory_path(filter: 'ssh_keys'), status: :found }
      format.js { head :ok }
    end
  end

  private

  def filter_credentials
    if show_personal_access_tokens?
      ::PersonalAccessTokensFinder.new({ user: users, impersonation: false, sort: 'id_desc' }).execute
    elsif show_ssh_keys?
      ::KeysFinder.new({ users: users, key_type: 'ssh' }).execute
    end
  end

  def users
    raise NotImplementedError, "#{self.class} does not implement #{__method__}"
  end
end
