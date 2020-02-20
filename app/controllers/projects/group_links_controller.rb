# frozen_string_literal: true

class Projects::GroupLinksController < Projects::ApplicationController
  layout 'project_settings'
  before_action :authorize_admin_project!
  before_action :authorize_admin_project_member!, only: [:update]

  def index
    redirect_to namespace_project_settings_members_path
  end

  def create
    if group
      result = Projects::GroupLinks::CreateService.new(project, current_user, group_link_create_params).execute(group)
      group_link_created = result[:status] == :success

      return render_404 if result[:http_status] == 404
    end

    update_gitlab_subscription if group_link_created
    set_flash_message_on_create(result)

    redirect_to project_project_members_path(project)
  end

  def update
    @group_link = @project.project_group_links.find(params[:id])

    @group_link.update(group_link_params)

    update_gitlab_subscription
  end

  def destroy
    group_link = project.project_group_links.find(params[:id])

    ::Projects::GroupLinks::DestroyService.new(project, current_user).execute(group_link)

    update_gitlab_subscription

    respond_to do |format|
      format.html do
        redirect_to project_project_members_path(project), status: :found
      end
      format.js { head :ok }
    end
  end

  protected

  def group_link_params
    params.require(:group_link).permit(:group_access, :expires_at)
  end

  def group_link_create_params
    params.permit(:link_group_access, :expires_at)
  end

  private

  # Noop on FOSS
  def update_gitlab_subscription
  end

  def group
    return @group if defined?(@group)

    @group = params[:link_group_id].present? ? Group.find(params[:link_group_id]) : nil
  end

  def set_flash_message_on_create(result)
    flash[:alert] = if group
                      result[:message] if result[:http_status] == 409
                    else
                      _('Please select a group.')
                    end
  end
end

Projects::GroupLinksController.prepend_if_ee('EE::Projects::GroupLinksController')
