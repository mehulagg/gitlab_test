# frozen_string_literal: true

module API
  class ProjectTerraformStates < Grape::API
    helpers ::API::Helpers::PackagesManagerClientsHelpers

    helpers do
      def find_personal_access_token
        find_personal_access_token_from_http_basic_auth
      end
    end

    before { authenticate! }

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end

    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Get a statefile by its name'

      params do
        requires :name, type: String, desc: 'The name of the statefile'
      end

      get ':id/terraform_states/:name' do
        state = user_project.terraform_states.find_by!(name: params[:name])
        content_type 'text/plain'
        body state.value
      end

      desc 'Add or update state for the project'

      params do
        requires :name, type: String, desc: 'The name of the statefile'
      end

      post ":id/terraform_states/:name" do
        state = user_project.terraform_states.find_by(name: params[:name])
        value = request.body.string

        if state.present?
          state.update!(value: value)
        else
          state = user_project.terraform_states.create!(name: params[:name], value: value)
        end

        content_type 'text/plain'
        body state.value
      end

      delete ":id/terraform_states/:name" do
        state = user_project.terraform_states.find_by!(name: params[:name])
        state.delete
      end
    end
  end
end
