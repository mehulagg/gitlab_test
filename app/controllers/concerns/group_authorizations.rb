# frozen_string_literal: true

module GroupAuthorizations
  extend ActiveSupport::Concern

  private

  def authorize_admin_group!
    unless can?(current_user, :admin_group, group)
      render_404
    end
  end

  def authorize_create_deploy_token!
    unless can?(current_user, :create_deploy_token, group)
      render_404
    end
  end

  def authorize_destroy_deploy_token!
    unless can?(current_user, :destroy_deploy_token, group)
      render_404
    end
  end

  def authorize_admin_group_member!
    unless can?(current_user, :admin_group_member, group)
      render_403
    end
  end
end
