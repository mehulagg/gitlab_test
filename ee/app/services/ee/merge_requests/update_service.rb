# frozen_string_literal: true

module EE
  module MergeRequests
    module UpdateService
      extend ::Gitlab::Utils::Override

      include CleanupApprovers

      override :execute
      def execute(merge_request)
        unless update_task_event?
          should_remove_old_approvers = params.delete(:remove_old_approvers)
          blocking_mr_refs = params.delete(:blocking_merge_request_refs)
          old_approvers = merge_request.overall_approvers(exclude_code_owners: true)
        end

        merge_request = super(merge_request)

        if should_remove_old_approvers && merge_request.valid?
          cleanup_approvers(merge_request, reload: true)
        end

        merge_request.reset_approval_cache!

        return merge_request if update_task_event?

        new_approvers = merge_request.overall_approvers(exclude_code_owners: true) - old_approvers

        if new_approvers.any?
          todo_service.add_merge_request_approvers(merge_request, new_approvers)
          notification_service.add_merge_request_approvers(merge_request, new_approvers, current_user)
        end

        # Correctly handle PATCH requests. If no blocking MR refs were sent,
        # update nothing
        handle_blocking_mrs(merge_request, refs: blocking_mr_refs) unless
          blocking_mr_refs.nil?

        merge_request
      end

      private

      def handle_blocking_mrs(merge_request, refs:)
        return unless merge_request.target_project.feature_available?(:blocking_merge_requests)

        # Parse out the magic "_remove_hidden" specifier from the list of refs
        remove_hidden, refs = refs.partition { |ref| ref == '_remove_hidden' }
        remove_hidden = remove_hidden.present?
        ids = Gitlab::ReferenceExtractor
          .new(merge_request.target_project)
          .analyze(refs.join(" "))
          .merge_requests
          .map(&:id)

        current = merge_request.merge_request_blocks_as_blockee

        visible, hidden = current.partition do |block|
          can?(current_user, :read_merge_request, block.blocking_merge_requests)
        end

        visible_ids = visible.map(&:blocking_merge_request_id)

        # Add any MRs that are newly requested
        MergeRequest.id_in(id: (ids - visible_ids)).each do |blocking_mr|
          # Don't add MRs the user can't access
          next unless can?(current_user, :read_merge_request, blocking_mr)

          merge_request.blocking_merge_requests << blocking_mr
        end

        # Remove any MRs that are no longer requested
        merge_request
          .merge_request_blocks_as_blockee
          .id_in(blocking_merge_request_id: (visible_ids - ids))
          .delete_all

        # Remove hidden MRs if requested
        hidden.each(&:destroy!) if remove_hidden
      end

      override :create_branch_change_note
      def create_branch_change_note(merge_request, branch_type, old_branch, new_branch)
        super

        reset_approvals(merge_request)
      end

      def reset_approvals(merge_request)
        target_project = merge_request.target_project

        merge_request.approvals.delete_all if target_project.reset_approvals_on_push
      end
    end
  end
end
