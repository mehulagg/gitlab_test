# frozen_string_literal: true

module EE
  module EnvironmentEntity
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      expose :rollout_status, if: -> (*) { can_read_deploy_board? }, using: ::RolloutStatusEntity

      expose :project_path do |environment|
        project_path(environment.project)
      end

      expose :logs_api_path, if: -> (*) { can_read_pod_logs? } do |environment|
        if environment.deployment_platform.nil?
          nil
        elsif environment.deployment_platform&.elastic_stack_available?
          expose_path api_v4_clusters_namespace__clusters__cluster_id_namespace__namespace_logs_logs_elasticsearch_path(cluster_id: environment.deployment_platform.cluster_id, namespace: environment.deployment_namespace, format: '.json')
        else
          expose_path api_v4_clusters_namespace__clusters__cluster_id_namespace__namespace_logs_logs_kubernetes_path(cluster_id: environment.deployment_platform.cluster_id, namespace: environment.deployment_namespace, format: '.json')
        end
      end

      expose :enable_advanced_logs_querying, if: -> (*) { can_read_pod_logs? } do |environment|
        environment.deployment_platform&.elastic_stack_available?
      end
    end

    private

    def can_read_pod_logs?
      can?(current_user, :read_pod_logs, environment.project)
    end

    def can_read_deploy_board?
      can?(current_user, :read_deploy_board, environment.project)
    end
  end
end
