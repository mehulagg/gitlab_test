# frozen_string_literal: true

module API
  class Clusters < Grape::API
    before { authenticate! }

    helpers do
      def authorize_read_pod_logs!
        not_found! unless can?(current_user, :read_pod_logs, environment.try(:project))
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def environment
        @environment ||= ::Clusters::KubernetesNamespace.where(namespace: params[:namespace], cluster_id: params[:cluster_id]).first.try(:environment)
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def logs
        if environment.nil?
          not_found!
          return
        end

        # ::Gitlab::UsageCounters::PodLogs.increment(environment.project.id)
        # ::Gitlab::PollingInterval.set_header(response, interval: 3_000)

        result = PodLogs::BaseService.new(environment, params: params).execute

        case result[:status]
        when :processing
          accepted!
        when :success
          result
        else
          render_api_error!("#{result[:message]} (last_step: #{result[:last_step]})", 400)
        end
      end
    end

    resource :clusters do
      before { authorize_read_pod_logs! }
      segment ':cluster_id/namespace/:namespace/logs' do
        params do
          optional :pod_name, type: String, desc: 'The name of pod you want to get logs for. Defaults to the first pod in the namespace if not specified.'
          optional :container_name, type: String, desc: 'The name of a container within the pod you want to get logs for. Defaults to the first container in the pod if not specified.'
        end
        get :kubernetes do
          logs
        end

        params do
          optional :pod_name, type: String, desc: 'The name of pod you want to get logs for. Defaults to the first pod in the namespace if not specified.'
          optional :container_name, type: String, desc: 'The name of a container within the pod you want to get logs for. Defaults to the first container in the pod if not specified.'
          optional :search, type: String, desc: 'Log message search terms.'
          optional :start, type: String, desc: 'Beginning of the time range of logs you are interested in.'
          optional :end, type: String, desc: 'End of the time range of logs you are interested in.'
        end
        get :elasticsearch do
          logs
        end
      end
    end

    #     desc 'Get a list of all project aliases' do
    #       success EE::API::Entities::ProjectAlias
    #     end
    #     params do
    #       use :pagination
    #     end
    #     get do
    #       present paginate(ProjectAlias.all), with: EE::API::Entities::ProjectAlias
    #     end

    #     desc 'Get info of specific project alias by name' do
    #       success EE::API::Entities::ProjectAlias
    #     end
    #     get 'k8s' do
    #       present project_alias, with: EE::API::Entities::ProjectAlias
    #     end

    #     desc 'Create a project alias'
    #     params do
    #       requires :project_id, type: String, desc: 'The ID or URL-encoded path of the project'
    #       requires :name, type: String, desc: 'The alias of the project'
    #     end
    #     post do
    #       project_alias = project.project_aliases.create(name: params[:name])

    #       if project_alias.valid?
    #         present project_alias, with: EE::API::Entities::ProjectAlias
    #       else
    #         render_validation_error!(project_alias)
    #       end
    #     end

    #     desc 'Delete a project alias by name'
    #     delete ':name' do
    #       project_alias.destroy

    #       no_content!
    #     end
    #   end
  end
end
