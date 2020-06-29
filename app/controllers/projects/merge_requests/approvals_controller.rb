# frozen_string_literal: true

module Projects
  module MergeRequests
    class ApprovalsController < Projects::MergeRequests::ApplicationController
      before_action :authorize_approve_merge_request!, only: [:create, :destroy]

      def show
        render_approvals_json
      end

      def create
        return render_404 unless can_be_approved_by?(merge_request, current_user)

        ::MergeRequests::ApprovalService
          .new(project, current_user)
          .execute(merge_request)

        render_approvals_json
      end

      def destroy
        if approved_by?(merge_request, current_user)
          ::MergeRequests::RemoveApprovalService
            .new(project, current_user)
            .execute(merge_request)
        end

        render_approvals_json
      end

      private

      def render_approvals_json
        respond_to do |format|
          format.json do
            render json: {}
          end
        end
      end

      def can_be_approved_by?(merge_request, user)
        !approved_by?
      end

      def approved_by?(merge_request, user)
        merge_request.approvals.select { |a| a.user_id == user.id }.present?
      end

      def preloaded_associations
        [:approved_by_users]
      end

      # Assigning both @merge_request and @issuable like in
      # `Projects::MergeRequests::ApplicationController`, and calling super if
      # we don't need the extra includes requires us to disable this cop.
      # rubocop: disable CodeReuse/ActiveRecord
      def merge_request
        @issuable = @merge_request ||=
          project
            .merge_requests.includes(preloaded_associations)
            .find_by!(iid: params[:merge_request_id])

        super
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end

Projects::MergeRequests::ApprovalsController.prepend_if_ee('EE::Projects::MergeRequests::ApprovalsController')
