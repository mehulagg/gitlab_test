# frozen_string_literal: true

module Gitlab
  module QuickActions
    module MergeRequestHelpers
      def mergeable?
        quick_action_target.persisted? && quick_action_target.can_be_merged_by?(current_user)
      end

      def merge_orchestration_service
        @merge_orchestration_service ||= MergeRequests::MergeOrchestrationService.new(project, current_user)
      end

      def preferred_auto_merge_strategy(merge_request)
        merge_orchestration_service.preferred_auto_merge_strategy(merge_request)
      end
    end
  end
end

Gitlab::QuickActions::MergeRequestHelpers.prepend_if_ee('EE::Gitlab::QuickActions::MergeRequestHelpers')
