# frozen_string_literal: true

class MergeRequestPolicy < IssuablePolicy
  rule { locked }.policy do
    prevent :reopen_merge_request
  end

  # Only users who can read the merge request can comment.
  # Although :read_merge_request is computed in the policy context,
  # it would not be safe to prevent :create_note there, since
  # note permissions are shared, and this would apply too broadly.
  rule { ~can?(:read_merge_request) }.prevent :create_note

  condition :non_fork_and_can_create_pipeline do
    !@subject.for_fork? && can?(:create_pipeline)
  end

  condition :fork_and_allowed_to_create_pipeline do
    @subject.for_fork? && @subject.target_project.allow_fork_pipelines_to_run_in_parent?
  end

  rule { non_fork_and_can_create_pipeline | fork_and_allowed_to_create_pipeline }.policy do
    enable :create_pipeline
  end
end

MergeRequestPolicy.prepend_if_ee('EE::MergeRequestPolicy')
