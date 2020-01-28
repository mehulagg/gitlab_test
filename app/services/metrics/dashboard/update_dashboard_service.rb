# frozen_string_literal: true

# Copies system dashboard definition in .yml file into designated
# .yml file inside `.gitlab/dashboards`
module Metrics
  module Dashboard
    class UpdateDashboardService < ::BaseService
      USER_DASHBOARDS_DIR = ::Metrics::Dashboard::ProjectDashboardService::DASHBOARD_ROOT

      def execute
        catch(:error) do
          throw(:error, error(_(%q(You cant commit to this project)), :forbidden)) unless push_authorized?

          result = ::Files::UpdateService.new(project, current_user, dashboard_attrs).execute
          throw(:error, result) unless result[:status] == :success

          success(result.merge(http_status: :created, dashboard: dashboard_details))
        end
      end

      private

      def dashboard_attrs
        {
          commit_message: params[:commit_message],
          file_path: new_dashboard_path,
          file_content: update_dashboard_content,
          encoding: 'text',
          branch_name: branch,
          start_branch: repository.branch_exists?(branch) ? branch : project.default_branch
        }
      end

      def dashboard_details
        {
          path: new_dashboard_path
        }
      end

      def push_authorized?
        Gitlab::UserAccess.new(current_user, project: project).can_push_to_branch?(branch)
      end

      def branch
        @branch ||= begin
          throw(:error, error(_('There was an error updating the dashboard, branch name is invalid.'), :bad_request)) unless valid_branch_name?
          throw(:error, error(_('There was an error updating the dashboard, branch named: %{branch} already exists.') % { branch: params[:branch] }, :bad_request)) unless new_or_default_branch? # temporary validation for first UI iteration

          params[:branch]
        end
      end

      def new_or_default_branch?
        !repository.branch_exists?(params[:branch]) || project.default_branch == params[:branch]
      end

      def valid_branch_name?
        Gitlab::GitRefValidator.validate(params[:branch])
      end

      def new_dashboard_path
        File.join(USER_DASHBOARDS_DIR, params[:file_name])
      end

      def update_dashboard_content
        ::PerformanceMonitoring::PrometheusDashboard.from_json(params[:file_content]).to_yaml
      end

      def repository
        @repository ||= project.repository
      end
    end
  end
end
