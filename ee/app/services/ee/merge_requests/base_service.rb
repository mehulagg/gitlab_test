# frozen_string_literal: true

module EE
  module MergeRequests
    module BaseService
      private

      def filter_params(merge_request)
        unless current_user.can?(:update_approvers, merge_request)
          params.delete(:approvals_before_merge)
          params.delete(:approver_ids)
          params.delete(:approver_group_ids)
        end

        filter_approval_rule_groups_and_users(merge_request)

        super
      end

      def filter_approval_rule_groups_and_users(merge_request)
        return unless params.key?(:approval_rules_attributes)

        # For efficiency, we avoid repeated check per rule for eligibility of users and groups
        # but instead consolidate all ids so eligibility can be checked in one go.
        group_ids = params[:approval_rules_attributes].flat_map { |hash| hash[:group_ids] }
        user_ids = params[:approval_rules_attributes].flat_map { |hash| hash[:user_ids] }

        # rubocop: disable CodeReuse/ActiveRecord
        group_ids = ::Group.id_in(group_ids).public_or_visible_to_user(current_user).pluck(:id) unless group_ids.empty?
        user_ids = merge_request.project.members_among(::User.id_in(user_ids)).pluck(:id) unless user_ids.empty?
        # rubocop: enable CodeReuse/ActiveRecord

        params[:approval_rules_attributes].each do |rule_attributes|
          if rule_attributes.key?(:group_ids)
            provided_group_ids = rule_attributes[:group_ids].map(&:to_i)
            rule_attributes[:group_ids] = provided_group_ids & group_ids
          end

          if rule_attributes.key?(:user_ids)
            provided_user_ids = rule_attributes[:user_ids].map(&:to_i)
            rule_attributes[:user_ids] = provided_user_ids & user_ids
          end
        end
      end

      def create_pipeline_for(merge_request, user)
        return super unless can_create_merge_request_pipeline_for?(merge_request)

        ret = ::MergeRequests::MergeToRefService.new(merge_request.project, user)
                                                .execute(merge_request)

        return super unless ret[:status] == :success

        ::Ci::CreatePipelineService.new(merge_request.source_project, user,
                                        ref: merge_request.merge_ref_path,
                                        checkout_sha: ret[:commit_id],
                                        target_sha: ret[:target_id],
                                        source_sha: ret[:source_id])
          .execute(:merge_request_event, merge_request: merge_request)
      end

      def can_create_merge_request_pipeline_for?(merge_request)
        return false if merge_request.work_in_progress?
        return false unless project.merge_pipelines_enabled?
        return false unless can_use_merge_request_ref?(merge_request)

        can_create_pipeline_for?(merge_request)
      end
    end
  end
end
