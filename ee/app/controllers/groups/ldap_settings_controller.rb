# frozen_string_literal: true

class Groups::LdapSettingsController < Groups::ApplicationController
  before_action :group
  before_action :require_ldap_enabled
  before_action :authorize_admin_group!
  before_action :authorize_manage_ldap_settings!

  def update
    if @group.update(ldap_settings_params)
      redirect_back_or_default(default: { action: 'index' }, options: { notice: _('LDAP settings updated') })
    else
      redirect_back_or_default(default: { action: 'index' }, options: { alert: _('Could not update the LDAP settings') })
    end
  end

  private

  def authorize_manage_ldap_settings!
    render_404 unless can?(current_user, :admin_ldap_group_settings, group)
  end

  def require_ldap_enabled
    render_404 unless Gitlab.config.ldap.enabled
  end

  def ldap_settings_params
    attrs = %i[lock_membership_to_ldap]

    params.require(:group).permit(attrs)
  end
end
