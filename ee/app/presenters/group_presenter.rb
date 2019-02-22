# frozen_string_literal: true

class GroupPresenter < Gitlab::View::Presenter::Delegated
  presents :group

  def group_view_supports_request_format?
    if request.format.html?
      true
    elsif request.format.atom?
      supports_atom_request_format?
    else
      false
    end
  end

  def group_view_redirect_needed?
    group_view != EE::User::DEFAULT_GROUP_VIEW
  end

  def group_view_url(group)
    case group_view
    when 'security_dashboard'
      helpers.group_security_dashboard_url(group)
    else
      raise ArgumentError, "Unknown non-default group_view setting '#{group_view}' for a user #{current_user}"
    end
  end

  private

  def group_view
    strong_memoize(:group_view) do
      current_user&.group_view
    end
  end

  def supports_atom_request_format?
    group_view == EE::User::DEFAULT_GROUP_VIEW
  end
end
