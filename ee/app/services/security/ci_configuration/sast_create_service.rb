# frozen_string_literal: true

module Security
  module CiConfiguration
    class SastCreateService < ::BaseService
      def initialize(project, current_user, params)
        @project = project
        @current_user = current_user
        @params = params
        @branch_name = @project.repository.next_branch('set-sast-config')
      end

      def execute
        result = ::Files::MultiService.new(@project, @current_user, attributes).execute

        if result[:status] == :success
          result[:success_path] = successful_change_path
        else
          result[:errors] = result[:message]
        end

        result
      end

      private

      def attributes
        actions = Security::CiConfiguration::SastBuildActions.new(@project.auto_devops_enabled?, @params, existing_gitlab_ci_content, default_sast_values).generate

        @project.repository.add_branch(@current_user, @branch_name, @project.default_branch)
        message = _('Set .gitlab-ci.yml to enable or configure SAST')

        {
          commit_message: message,
          branch_name: @branch_name,
          start_branch: @branch_name,
          actions: actions
        }
      end

      def existing_gitlab_ci_content
        gitlab_ci_yml = @project.repository.gitlab_ci_yml_for(@project.repository.root_ref_sha)
        YAML.safe_load(gitlab_ci_yml) if gitlab_ci_yml
      end

      def default_sast_values
        result = Security::CiConfiguration::SastParserService.new(@project)

        global_defaults = result.configuration["global"].collect { |k| [k["field"], k["default_value"]] }.to_h
        pipeline_defaults = result.configuration["pipeline"].collect { |k| [k["field"], k["default_value"]] }.to_h
        global_defaults.merge!(pipeline_defaults)
      end

      def successful_change_path
        description = _('Set .gitlab-ci.yml to enable or configure SAST security scanning using the GitLab managed template. You can [add variable overrides](https://docs.gitlab.com/ee/user/application_security/sast/#customizing-the-sast-settings) to customize SAST settings.')
        merge_request_params = { source_branch: @branch_name, description: description }
        Gitlab::Routing.url_helpers.project_new_merge_request_url(@project, merge_request: merge_request_params)
      end
    end
  end
end
