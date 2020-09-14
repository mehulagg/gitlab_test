# frozen_string_literal: true

module Environments
  class ScheduleUpdateCanaryService < ::BaseService
    JOB_NAME = 'update_canary_ingress'
    AUTO_DEPLOY_IMAGE = 'registry.gitlab.com/gitlab-org/cluster-integration/auto-deploy-image:v2'

    def execute(environment)
      unless Feature.enabled?(:update_canary_ingress, project)
        return error(_('Feature flag is not enabled on this project.'))
      end

      unless can_update_environment?(environment)
        return error(_('You do not have permission to update the environment.'))
      end

      unless params[:weight] && (0..100).include?(params[:weight].to_i)
        return error(_('Canary weight must be specified and valid range (0..100)'))
      end

      unless environment.canary_exist?
        return error(_('Canary track does not exist in the environment'))
      end

      if updating_canary_for?(environment)
        return error(_('Already a pipeline job started updating the canary ingress'))
      end

      pipeline = Ci::CreatePipelineService.new(project, current_user, ref: environment.ref)
        .execute(:canary_weight_update, content: ci_yaml)

      if result[:status] == :success
        success(environment: environment)
      else
        error(environment.errors.full_messages.join(','), http_status: :bad_request)
      end
    end

    private

    def can_update_environment?(environment)
      can?(current_user, :update_environment, environment)
    end

    def updating_canary_for?(environment)
      project.ci_builds.where(expanded_environment_name: name, name: JOB_NAME).running.exist?
    end

    def ci_yaml
      {
        stages: %w[update],
        JOB_NAME => {
          image: AUTO_DEPLOY_IMAGE,
          scripts: ["auto-deploy download_chart",
                    "auto-deploy scale canary #{params[:weight]}"],
          environment: {
            name: environment.name,
            action: :prepare
          }
        }
      }.to_yaml
    end
  end
end
