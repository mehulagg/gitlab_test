# frozen_string_literal: true

module EE
  module Gitlab
    module QuickActions
      module MergeRequestActions
        include ::Gitlab::QuickActions::DslNew

        types MergeRequest

        command :approve do
          desc _('Approve a merge request')
          explanation _('Approve the current merge request.')
          condition do
            merge_request.persisted? && merge_request.can_approve?(current_user) && !merge_request.project.require_password_to_approve?
          end
          action do
            ::MergeRequests::ApprovalService.new(merge_request.project, current_user).execute(merge_request)
            info _('Approved the current merge request.')
          end
        end

        helpers ::Gitlab::QuickActions::MergeRequestHelpers
      end
    end
  end
end
