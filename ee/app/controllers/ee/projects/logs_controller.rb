# frozen_string_literal: true

module EE
  module Projects
    module LogsController
      extend ActiveSupport::Concern

      prepended do
        before_action :authorize_read_pod_logs!, only: [:show]
        before_action :cluster, only: [:show]
        before_action do
          push_frontend_feature_flag(:environment_logs_use_vue_ui)
        end
      end

      def show
        respond_to do |format|
          format.html do
            if cluster.nil?
              render :empty_logs
            else
              render :show
            end
          end

          format.json do
            ::Gitlab::UsageCounters::PodLogs.increment(project.id)
            ::Gitlab::PollingInterval.set_header(response, interval: 3_000)

            result = PodLogsService.new(cluster, params: filter_params).execute

            if result[:status] == :processing
              head :accepted
            elsif result[:status] == :success
              render json: result
            else
              render status: :bad_request, json: result
            end
          end
        end
      end

      def filters
        render json: { pods: cluster.kubeclient.get_pods.map { |pod| { name: pod.metadata.name, namespace: pod.metadata.namespace, containers: pod.spec.containers.map(&:name)} } }
      end

      private

      def show_params
        params.permit(:cluster)
      end

      def filter_params
        params.permit(:namespace, :container, :pod)
      end

      def cluster
        @clusters ||= project.clusters
        @cluster ||= if show_params.key?(:cluster)
                           project.clusters.where(name: show_params[:cluster]).first
                         else
                           project.default_environment.deployment_platform.cluster
                         end
      end
    end
  end
end
