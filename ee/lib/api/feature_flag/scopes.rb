# frozen_string_literal: true

module API
  module FeatureFlag
    class Scopes < Grape::API
      include PaginationParams

      FEATURE_FLAG_ENDPOINT_REQUIREMETS = API::NAMESPACE_OR_PROJECT_REQUIREMENTS
          .merge(name: API::NO_SLASH_URL_PART_REGEX)

      before { authorize_read_feature_flag! }

      params do
        requires :id, type: String, desc: 'The ID of a project'
        requires :name, type: String, desc: 'The name of the feature flag'
      end
      resource 'projects/:id/feature_flags/:name/scopes', requirements: FEATURE_FLAG_ENDPOINT_REQUIREMETS do
        desc 'Get all scopes of a feature flag' do
          detail 'This feature was introduced in GitLab 12.4.'
          success EE::API::Entities::FeatureFlag::Scope
        end
        params do
          use :pagination
        end
        get do
          present paginate(feature_flag.scopes), with: EE::API::Entities::FeatureFlag::Scope
        end

        desc 'Get a scope of a feature flag' do
          detail 'This feature was introduced in GitLab 12.4.'
          success EE::API::Entities::FeatureFlag::Scope
        end
        params do
          requires :scope_id, type: String
        end
        get ':scope_id' do
          present scope, with: EE::API::Entities::FeatureFlag::Scope
        end

        desc 'Create a new scope for a feature flag' do
          detail 'This feature was introduced in GitLab 12.4.'
          success EE::API::Entities::FeatureFlag::Scope
        end
        params do
          requires :environment_scope, type: String
          requires :active, type: Boolean
          requires :strategies, type: JSON
        end
        post do
          puts "#{self.class.name} - #{__callee__}: 1"
          authorize_update_feature_flag!

          param = { scopes_attributes: [declared_params(include_missing: false)] }

          puts "#{self.class.name} - #{__callee__}: param: #{param}"

          result = ::FeatureFlags::UpdateService
            .new(user_project, current_user, param)
            .execute(feature_flag)

          if result[:status] == :success
            present result[:feature_flag].scopes.last, with: EE::API::Entities::FeatureFlag::Scope
          else
            render_api_error!(result[:message], result[:http_status])
          end
        end

        desc 'Update a scope of a feature flag' do
          detail 'This feature was introduced in GitLab 12.4.'
          success EE::API::Entities::FeatureFlag::Scope
        end
        params do
          requires :scope_id, type: String
          optional :environment_scope, type: String
          optional :active, type: Boolean
          optional :strategies, type: JSON
        end
        put ':scope_id' do
          authorize_update_feature_flag!

          param = declared_params(include_missing: false)
          param[:id] = param.delete(:scope_id)
          param = { scopes_attributes: [param] }

          result = ::FeatureFlags::UpdateService
            .new(user_project, current_user, param)
            .execute(feature_flag)

          if result[:status] == :success
            present scope.reload, with: EE::API::Entities::FeatureFlag::Scope
          else
            render_api_error!(result[:message], result[:http_status])
          end
        end

        desc 'Delete a scope from a feature flag' do
          detail 'This feature was introduced in GitLab 12.4.'
          success EE::API::Entities::FeatureFlag::Scope
        end
        params do
          optional :scope_id,         type: String, desc: 'The scope'
        end
        delete ':scope_id' do
          authorize_update_feature_flag!

          param = { scopes_attributes: [{ id: scope.id, _destroy: 1 }] }

          result = ::FeatureFlags::UpdateService
            .new(user_project, current_user, param)
            .execute(feature_flag)

          if result[:status] == :success
            present scope, with: EE::API::Entities::FeatureFlag::Scope
          else
            render_api_error!(result[:message], result[:http_status])
          end
        end
      end

      helpers do
        def authorize_read_feature_flag!
          authorize! :read_feature_flag, feature_flag
        end

        def authorize_update_feature_flag!
          authorize! :update_feature_flag, feature_flag
        end

        def feature_flag
          @feature_flag ||= user_project.operations_feature_flags.find_by_name!(params[:name])
        end

        def scope
          @scope ||= feature_flag.scopes.find_by_id!(params[:scope_id])
        end
      end
    end
  end
end
