# frozen_string_literal: true

module Projects
  class LogsController < Projects::ApplicationController
    before_action :authorize_read_pod_logs!
    before_action :environment
    before_action do
      push_frontend_feature_flag(:environment_logs_use_vue_ui)
    end

    def index
      render environment.nil? ? :empty_logs : :index
    end

    def k8s
      ::Gitlab::UsageCounters::PodLogs.increment(project.id)
      ::Gitlab::PollingInterval.set_header(response, interval: 3_000)

      result = PodLogsService.new(environment, params: filter_params).execute

      case result[:status]
      when :processing
        head :accepted
      when :success
        render json: result
      else
        render status: :bad_request, json: result
      end
    end

    def filters
      environments = project.environments.sort_by(&:name).map do |e|
        item = {
          name: e.name,
          namespace: e.deployment_namespace,
          es_enabled: false,
          pods: []
        }

        deployment_platform = e.deployment_platform
        next item if deployment_platform.nil?

        item[:es_enabled] = !!deployment_platform.elastic_stack_client

        pods = deployment_platform.kubeclient.get_pods(namespace: e.deployment_namespace)
        item[:pods] = pods.map do |pod|
          {
            name: pod.metadata.name,
            containers: pod.spec.containers.map(&:name)
          }
        end

        item
      end

      render json: environments
    end

    private

    def index_params
      params.permit(:environment_name)
    end

    def filter_params
      params.permit(:container_name, :pod_name)
    end

    def environment
      @environment ||= if index_params.key?(:environment_name)
                         EnvironmentsFinder.new(project, current_user, name: index_params[:environment_name]).find.first
                       else
                         project.default_environment
                       end
    end
  end
end
