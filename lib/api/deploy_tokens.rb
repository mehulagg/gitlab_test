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
      requires :id, type: String, desc: 'The ID of a project'
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

      desc 'Delete a project deploy token' do
        detail 'This feature was introduced in GitLab 12.9'
      end
      params do
        requires :token_id, type: Integer, desc: 'The deploy token ID'
      end
      delete ':id/deploy_tokens/:token_id' do
        authorize!(:destroy_deploy_token, user_project)

        deploy_token = user_project.project_deploy_tokens
          .find_by_deploy_token_id(params[:token_id])

        not_found!('Deploy Token') unless deploy_token

        deploy_token.destroy
        no_content!
      end
    end
  end
end
