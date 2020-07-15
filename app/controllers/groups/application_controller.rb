# frozen_string_literal: true

class Groups::ApplicationController < ApplicationController
  include RoutableActions
  include ControllerWithCrossProjectAccessCheck
  include GroupAuthorizations

  layout 'group'

  skip_before_action :authenticate_user!
  before_action :group
  requires_cross_project_access

  private

  def group
    @group ||= find_routable!(Group, params[:group_id] || params[:id])
  end

  def group_projects
    @projects ||= GroupProjectsFinder.new(group: group, current_user: current_user).execute
  end

  def group_projects_with_subgroups
    @group_projects_with_subgroups ||= GroupProjectsFinder.new(
      group: group,
      current_user: current_user,
      options: { include_subgroups: true }
    ).execute
  end

  def build_canonical_path(group)
    params[:group_id] = group.to_param

    url_for(safe_params)
  end
end

Groups::ApplicationController.prepend_if_ee('EE::Groups::ApplicationController')
