# frozen_string_literal: true

module API
  class ProjectTerraformStates < Grape::API
    LockConflictError = Class.new(StandardError)

    rescue_from LockConflictError do |e|
      error!(e, 409)
    end

    helpers ::API::Helpers::PackagesManagerClientsHelpers

    helpers do
      def find_personal_access_token
        super || find_personal_access_token_from_http_basic_auth
      end

      def check_lock!(state, locker_id)
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
        # check if person that wants to update the state is the same person that has locked it
        # when locking is used and update is called, the ID if locker is passed in query string params

        if state.present?
          check_lock!(state, params[:ID])
          state.update!(value: value)
        else
          # ??should we put lock first, before creating new state??
          state = user_project.terraform_states.create!(name: params[:name], value: value)
        end

        content_type 'text/plain'
        body state.value
      end

      delete ":id/terraform_states/:name" do
        state = user_project.terraform_states.find_by!(name: params[:name])
        # check if person that wants to update the state is the same person that has locked it
        # when locking is used and delete is called, the ID if locker is passed in query string params
        check_lock!(state, params[:ID])
        state.delete
        content_type 'text/plain'
        body ""
      end

      post ":id/terraform_states/:name/lock" do
        # lock should not break even if state is not created yet
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
end
