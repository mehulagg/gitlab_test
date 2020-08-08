# frozen_string_literal: true

module Branches
  class DeleteService < BaseService
    def execute(branch_name)
      repository = project.repository
      branch = repository.find_branch(branch_name)

      unless current_user.can?(:push_code, project)
        return ServiceResponse.error(
          message: 'You dont have push access to repo',
          http_status: 405)
      end

      unless branch
        return ServiceResponse.error(
          message: 'No such branch',
          http_status: 404)
      end

      if repository.rm_branch(current_user, branch_name)
        publish_event(branch_name)
        ServiceResponse.success(message: 'Branch was deleted')
      else
        ServiceResponse.error(
          message: 'Failed to remove branch',
          http_status: 400)
      end
    rescue Gitlab::Git::PreReceiveError => ex
      ServiceResponse.error(message: ex.message, http_status: 400)
    end

    private

    def publish_event(branch_name)
      ref = "#{::Gitlab::Git::BRANCH_REF_PREFIX}#{branch_name}"
      event = Repositories::BranchDeletedEvent.new(data: { project_id: project.id, user_id: current_user.id, ref: ref })
      Gitlab::EventStore.publish(event)
    end
  end
end
