# frozen_string_literal: true

module API
  class DeployTokens < Grape::API
    include PaginationParams

    desc 'Return all deploy tokens' do
      detail 'This feature was introduced in GitLab 12.9.'
      success Entities::DeployToken
    end
    params do
      use :pagination
    end
    get 'deploy_tokens' do
      authenticated_as_admin!

      present paginate(DeployToken.all), with: Entities::DeployToken
    end

    params do
      requires :id, type: Integer, desc: 'The ID of a project'
    end
    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      params do
        use :pagination
      end
      desc 'List deploy tokens for a project' do
        detail 'This feature was introduced in GitLab 12.9'
        success Entities::DeployToken
      end
      get ':id/deploy_tokens' do
        authorize!(:read_deploy_token, user_project)

        present paginate(user_project.deploy_tokens), with: Entities::DeployToken
      end
    end

    params do
      requires :id, type: String, desc: 'The ID of a group'
    end
    resource :groups, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      params do
        requires :name, type: String, desc: 'The name of the deploy token'
        requires :expires_at, type: DateTime, desc: 'When the deploy token expires'
        requires :read_repository, type: Boolean, desc: 'Indicates if the deploy token has read_repository scope'
        requires :read_registry, type: Boolean, desc: 'Indicates if the deploy token has read_registry scope'
        requires :username, type: String, desc: 'The username of the deploy token'
      end
      desc 'Create a group deploy token' do
        detail 'This feature was introduced in GitLab 12.9'
        success Entities::DeployTokenWithToken
      end
      post ':id/deploy_tokens' do
        authorize!(:create_deploy_token, user_group)

        deploy_token = ::Groups::DeployTokens::CreateService.new(
          user_group, current_user, declared(params)
        ).execute

        present deploy_token, with: Entities::DeployTokenWithToken
      end
    end
  end
end
