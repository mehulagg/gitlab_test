# frozen_string_literal: true

module API
  class ProjectTerraformStates < Grape::API
    rescue_from LockConflictError do |e|
      error!(e, 409)
    end

    helpers ::API::Helpers::PackagesManagerClientsHelpers

    helpers do
      def find_personal_access_token
        super || find_personal_access_token_from_http_basic_auth
      end

      def check_lock!(locker_id)
        if state.locked?
          lock_owner = JSON.parse(state.lock_info)["ID"]
          raise LockConflictError.new unless locker_id == lock_owner
        end
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
        check_lock!(params[:ID])

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
        check_lock!(params[:ID])
        state.delete
        content_type 'text/plain'
        body ""
      end

      post ":id/terraform_states/:name/lock" do
        state = user_project.terraform_states.find_or_create_by(name: params[:name])
        value = request.body.string

        content_type 'text/plain'

        if state.locked?
          status 409
          body state.lock_info
        else
          state.lock!(value)
          status 200
          body value
        end
      end

      delete ":id/terraform_states/:name/lock" do
        state = user_project.terraform_states.find_by!(name: params[:name])

        state.unlock!

        status 200
        content_type 'text/plain'
        body ""
      end
    end
  end

  class LockConflictError < StandardError
  end
end
