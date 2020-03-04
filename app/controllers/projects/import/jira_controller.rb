# frozen_string_literal: true

module Projects
  module Import
    class JiraController < Projects::ApplicationController
      before_action :authorize_admin_operations!

      def show
        if @project.import_state && @project.import_state.in_progress?
          @jira_projects = []
        else
          jira_client = @project.jira_service.client
          @jira_projects = jira_client.Project.all.map { |p| ["#{p.name}(#{p.key})", p.key] }
        end

        flash[:notice] = _("Import %{status}") % { status: @project.import_state.status } if @project.import_state.present?
      end

      def import
        import_state = @project.import_state
        if import_state.present?
          if import_state.in_progress?
            redirect_to project_import_jira_path(@project)
            return
          end
        else
          import_state = @project.create_import_state
        end

        jira_data = {
          jira: {
            jira_project_key: params[:jira_project_key]
          }
        }

        @project.create_or_update_import_data(data: jira_data)
        @project.import_type = 'jira'
        if @project.save
          import_state.schedule
        end

        redirect_to project_import_jira_path(@project)
      end
    end
  end
end
