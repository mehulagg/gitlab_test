# frozen_string_literal: true

module Ci
  class UnlockArtifactsWorker
    include ApplicationWorker
    include PipelineBackgroundQueue

    idempotent!

    # TODO: write specs for this class
    def perform(event_type, data)
      data = data.with_indifferent_access

      case event_type
      when Git::BranchPushedEvent.name, Git::TagPushedEvent.name
        return unless git_push_removing_ref?(data)

        ref = data.dig(:params, :change, :ref)
        unlock_artifacts(data[:project_id], data[:user_id], ref)
      when Repositories::BranchDeletedEvent.name, Repositories::TagDeletedEvent.name
        ref = data.dig(:ref)
        unlock_artifacts(data[:project_id], data[:user_id], ref)
      end
    end

    private

    def git_push_removing_ref?(data)
      newrev = data.dig(:params, :change, :newrev)
      Gitlab::Git.blank_ref?(newrev)
    end

    def unlock_artifacts(project_id, user_id, ref)
      ::Project.find_by_id(project_id).try do |project|
        ::User.find_by_id(user_id).try do |user|
          project.ci_refs.find_by_ref_path(ref).try do |ci_ref|
            ::Ci::UnlockArtifactsService.new(project, user).execute(ci_ref)
          end
        end
      end
    end
  end
end
