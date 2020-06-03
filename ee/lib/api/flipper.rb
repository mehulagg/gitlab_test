# frozen_string_literal: true

module API
  class Flipper < Grape::API
    include PaginationParams

    namespace :feature_flags do
      resource :flipper, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
        params do
          requires :project_id, type: String, desc: 'The ID of a project'
          optional :instance_id, type: String, desc: 'The Instance ID of GitLab Feature Flag Client'
          optional :app_name, type: String, desc: 'The Application Name of GitLab Feature Flag Client'
        end
        route_param :project_id do
          before do
            authorize_by_instance_id!
            authorize_feature_flags_feature!
          end

          # https://github.com/jnunemaker/flipper/blob/master/docs/api/README.md
          get 'features' do
            present :features, feature_flags, with: ::EE::API::Entities::FlipperFeature
          end

          get 'features/:feature_name' do
            present feature_flags.find_by_name(params[:feature_name]), with: ::EE::API::Entities::FlipperFeature
          end
        end
      end
    end

    helpers do
      def project
        @project ||= find_project(params[:project_id])
      end

      def instance_id
        params[:instance_id]
      end

      def app_name
        params[:app_name]
      end

      def authorize_by_instance_id!
        unauthorized! unless Operations::FeatureFlagsClient
          .find_for_project_and_token(project, instance_id)
      end

      def authorize_feature_flags_feature!
        forbidden! unless project.feature_available?(:feature_flags)
      end

      def feature_flags
        return [] unless app_name.present?

        Operations::FeatureFlag.for_client(project, app_name)
      end
    end
  end
end
