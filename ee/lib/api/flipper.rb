# frozen_string_literal: true

module API
  class Flipper < Grape::API
    include PaginationParams

    before do
      # not_found! unless ::Feature.enabled?(:gitlab_feature_flags_flipper_api) # TODO:
    end

    namespace :feature_flags do
      ##
      # Flipper API https://github.com/jnunemaker/flipper/blob/master/docs/api/README.md
      resource :flipper, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
        params do
          requires :project_id, type: String, desc: 'The ID of a project'
        end
        route_param :project_id do
          before do
            authorize_by_instance_id!
            authorize_feature_flags_feature!
          end

          resource :features, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
            desc 'Get all features'
            get do
              present :features, feature_flags, with: ::EE::API::Entities::FlipperFeature
            end

            desc 'Create a new feature'
            params do
              requires :name, type: String, desc: 'The name of the feature'
            end
            post do
              create_params = declared_params.merge(version: 'new_version_flag')
              result = ::FeatureFlags::CreateService.new(project, project.owner, create_params).execute

              if result[:status] == :success
                present result[:feature_flag], with: ::EE::API::Entities::FlipperFeature
              else
                render_api_error!(result[:message], result[:http_status])
              end
            end

            params do
              requires :feature_name, type: String, desc: 'The name of the feature to retrieve'
            end
            resource ':feature_name', requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
              desc 'Retrieve a feature'
              get do
                present feature_flag, with: ::EE::API::Entities::FlipperFeature
              end

              desc 'Delete a feature'
              delete do
                result = ::FeatureFlags::DestroyService.new(project, project.owner).execute(feature_flag)

                if result[:status] == :success
                  present result[:feature_flag], with: ::EE::API::Entities::FlipperFeature
                else
                  render_api_error!(result[:message], result[:http_status])
                end
              end

              desc 'Clear a feature'
              delete :clear do
                strategies_attributes = feature_flag.strategies.map do |strategy|
                  { id: strategy.id, _destroy: true }
                end

                result = ::FeatureFlags::UpdateService
                  .new(project, project.owner, strategies_attributes: strategies_attributes)
                  .execute(feature_flag)

                if result[:status] == :success
                  present result[:feature_flag], with: ::EE::API::Entities::FlipperFeature
                else
                  render_api_error!(result[:message], result[:http_status])
                end
              end

              desc 'Boolean enable a feature'
              post :boolean do
                add_strategy(Operations::FeatureFlags::Strategy::STRATEGY_DEFAULT, {})
              end

              desc 'Boolean disable a feature'
              delete :boolean do
                delete_strategy(Operations::FeatureFlags::Strategy::STRATEGY_DEFAULT)
              end

              desc 'Enable Group'
              params do
                requires :name, type: String, desc: 'The name of a registered group to enable'
              end
              post :groups do
                not_implemented!
              end

              desc 'Disable Group'
              params do
                requires :name, type: String, desc: 'The name of a registered group to disable'
              end
              delete :groups do
                not_implemented!
              end

              desc 'Enable Actor'
              params do
                requires :flipper_id, type: String, desc: 'The flipper_id of actor to enable'
              end
              post :actors do
                add_strategy(Operations::FeatureFlags::Strategy::STRATEGY_USERWITHID,
                             userIds: params[:flipper_id])
              end

              desc 'Disable Actor'
              params do
                requires :flipper_id, type: String, desc: 'The flipper_id of actor to disable'
              end
              delete :actors do
                delete_strategy(Operations::FeatureFlags::Strategy::STRATEGY_USERWITHID)
              end

              desc 'Enable Percentage of Actors'
              params do
                requires :percentage, type: Integer, desc: 'The percentage of actors to enable'
              end
              post :percentage_of_actors do
                add_strategy(Operations::FeatureFlags::Strategy::STRATEGY_GRADUALROLLOUTUSERID,
                             percentage: params[:percentage])
              end

              desc 'Disable Percentage of Actors'
              delete :percentage_of_actors do
                delete_strategy(Operations::FeatureFlags::Strategy::STRATEGY_GRADUALROLLOUTUSERID)
              end

              desc 'Enable Percentage of Time'
              params do
                requires :percentage, type: Integer, desc: 'The percentage of time to enable'
              end
              post :percentage_of_time do
                not_implemented!
              end

              desc 'Disable Percentage of Time'
              delete :percentage_of_time do
                not_implemented!
              end
            end
          end

          desc 'Check if features are enabled for an actor'
          params do
            requires :keys, type: String, desc: 'comma-separated list of features to check'
          end
          get 'actors/:flipper_id' do
            not_implemented!
          end
        end
      end
    end

    helpers do
      def project
        @project ||= find_project(params[:project_id])
      end

      def instance_id
        env['HTTP_GITLAB_FEATUREFLAG_INSTANCEID']
      end

      def authorize_by_instance_id!
        unauthorized! unless Operations::FeatureFlagsClient
          .find_for_project_and_token(project, instance_id)
      end

      def authorize_feature_flags_feature!
        forbidden! unless project.feature_available?(:feature_flags)
      end

      def feature_flags
        Operations::FeatureFlag.for_client(project, '*')
      end

      def feature_flag
        @feature_flag ||= project.operations_feature_flags
          .find_by_name!(params[:feature_name])
      end

      def add_strategy(name, parameters)
        update_params = {
          strategies_attributes: [{
            name: name,
            parameters: parameters,
            scopes_attributes: [{ environment_scope: '*' }]
          }]
        }
        result = ::FeatureFlags::UpdateService.new(project, project.owner, update_params).execute(feature_flag)

        if result[:status] == :success
          present result[:feature_flag], with: ::EE::API::Entities::FlipperFeature
        else
          render_api_error!(result[:message], result[:http_status])
        end
      end

      def delete_strategy(name)
        strategy = get_feature_flag_strategy(name)
        update_params = { strategies_attributes: [{ id: strategy.id, _destroy: true }] }
        result = ::FeatureFlags::UpdateService.new(project, project.owner, update_params).execute(feature_flag)

        if result[:status] == :success
          present result[:feature_flag], with: ::EE::API::Entities::FlipperFeature
        else
          render_api_error!(result[:message], result[:http_status])
        end
      end

      def get_feature_flag_strategy(name)
        feature_flag.strategies.includes(:scopes)
          .where(name: name, operations_scopes: { environment_scope: '*' })
          .take!
      end
    end
  end
end
