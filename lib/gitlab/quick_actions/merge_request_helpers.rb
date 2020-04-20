# frozen_string_literal: true

module Gitlab
  module QuickActions
    module MergeRequestHelpers
      def mergeable?
        merge_request.persisted? && merge_request.can_be_merged_by?(current_user)
      end

      def use_merge_orchestration_service?
        Feature.enabled?(:merge_orchestration_service, merge_request.project, default_enabled: true)
      end

      def merge_orchestration_service
        @merge_orchestration_service ||= MergeRequests::MergeOrchestrationService.new(project, current_user)
      end

      def preferred_strategy
        @strategy ||= merge_orchestration_service.preferred_auto_merge_strategy(merge_request)
      end

      def merge_request
        quick_action_target
      end
    end
  end
end

Gitlab::QuickActions::MergeRequestHelpers.prepend_if_ee('EE::Gitlab::QuickActions::MergeRequestHelpers')
