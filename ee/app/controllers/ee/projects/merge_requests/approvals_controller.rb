# frozen_string_literal: true

module EE
  module Projects
    module MergeRequests
      module ApprovalsController
        extend ::Gitlab::Utils::Override

        override :render_approvals_json
        def render_approvals_json
          respond_to do |format|
            format.json do
              render json: ::EE::API::Entities::ApprovalState.new(
                merge_request.approval_state,
                current_user: current_user
              )
            end
          end
        end

        override :preloaded_associations
        def preloaded_associations
          super + [approvers: :user]
        end

        override :approved_by?
        def approved_by?(merge_request, user)
          merge_request.has_approved?(user)
        end

        override :can_be_approved_by?
        def can_be_approved_by?(merge_request, user)
          merge_request.can_approve?(user)
        end
      end
    end
  end
end
