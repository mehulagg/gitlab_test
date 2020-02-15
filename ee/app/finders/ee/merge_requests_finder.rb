# frozen_string_literal: true

module EE
  module MergeRequestsFinder
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    override :filter_items
    def filter_items(items)
      items = super(items)
      items = by_approvers(items)
      by_approvals(items)
    end

    # Filter by merge requests approval list that contains specified user directly or as part of group membership
    def by_approvers(items)
      ::MergeRequests::ByApproversFinder
        .new(params[:approver_usernames], params[:approver_ids])
        .execute(items)
    end

    # Filter by merge requests that had been approved by specific users
    def by_approvals(items)
      ::MergeRequests::ByApprovalsFinder
        .new(params[:approved_by_usernames], params[:approved_by_ids])
        .execute(items)
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      override :scalar_params
      def scalar_params
        @scalar_params ||= super + [:approver_ids, :approved_by_ids]
      end

      override :array_params
      def array_params
        @array_params ||= super.merge(approver_usernames: [], approved_by_usernames: [])
      end
    end
  end
end
