# frozen_string_literal: true

module API
  class Unleash < Grape::API
    include PaginationParams

    namespace :feature_flags do
      resource :unleash, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
        params do
          requires :project_id, type: String, desc: 'The ID of a project'
          optional :instance_id, type: String, desc: 'The Instance ID of Unleash Client'
          optional :app_name, type: String, desc: 'The Application Name of Unleash Client'
        end
        route_param :project_id do
          before do
            authorize_by_unleash_instance_id!
            authorize_feature_flags_feature!
          end

          get do
            # not supported yet
            status :ok
          end

          desc 'Get a list of features (deprecated, v2 client support)'
          get 'features' do
            present :version, 1
            present :features, feature_flags, with: ::EE::API::Entities::UnleashFeature
          end

          desc 'Get a list of features'
          get 'client/features' do
            present :version, 1
            present :features, feature_flags, with: ::EE::API::Entities::UnleashFeature
          end

          post 'client/register' do
            # not supported yet
            status :ok
          end

          post 'client/metrics' do
            # not supported yet
            status :ok
          end
        end
      end
    end

    helpers do
      def project
        @project ||= find_project(params[:project_id])
      end

      def unleash_instance_id
        env['HTTP_UNLEASH_INSTANCEID'] || params[:instance_id]
      end

      def unleash_app_name
        env['HTTP_UNLEASH_APPNAME'] || params[:app_name]
      end

      def authorize_by_unleash_instance_id!
        unauthorized! unless Operations::FeatureFlagsClient
          .find_for_project_and_token(project, unleash_instance_id)
      end

      def authorize_feature_flags_feature!
        forbidden! unless project.feature_available?(:feature_flags)
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def feature_flags
        return [] unless unleash_app_name.present?

        raw_sql = <<~SQL
        WITH
          feature_flag_scopes_with_precedence AS (
            SELECT *,
            CASE
              WHEN environment_scope = '*' THEN 1
              WHEN environment_scope = ? THEN 3
              WHEN ? LIKE REPLACE(REPLACE(REPLACE(environment_scope, '%', '\%'), '_', '\_'), '*', '%') THEN 2
              ELSE 0
            END AS precedence
            FROM operations_feature_flag_scopes
          ),
          max_precedence_per_feature_flag AS (
            SELECT feature_flag_id, MAX(precedence) AS max_precedence
            FROM feature_flag_scopes_with_precedence
            GROUP BY feature_flag_id
          )
        SELECT
          operations_feature_flags.name,
          operations_feature_flags.description,
          feature_flag_scopes_with_precedence.active,
          operations_feature_flag_strategies.name AS strategy_name,
          operations_feature_flag_strategies.parameters AS strategy_parameters
        FROM operations_feature_flags
        JOIN feature_flag_scopes_with_precedence ON operations_feature_flags.id = feature_flag_scopes_with_precedence.feature_flag_id
        LEFT JOIN operations_feature_flag_strategies ON feature_flag_scopes_with_precedence.id = operations_feature_flag_strategies.feature_flag_scope_id
        JOIN max_precedence_per_feature_flag
          ON max_precedence_per_feature_flag.feature_flag_id = operations_feature_flags.id
          AND max_precedence_per_feature_flag.max_precedence = feature_flag_scopes_with_precedence.precedence
        WHERE operations_feature_flags.project_id = ?
        ORDER BY operations_feature_flags.name
        SQL

        Operations::FeatureFlag.find_by_sql([raw_sql, unleash_app_name, unleash_app_name, project.id])
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
