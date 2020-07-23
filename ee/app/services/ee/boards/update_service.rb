# frozen_string_literal: true

module EE
  module Boards
    module UpdateService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(board)
        unless parent.feature_available?(:scoped_issue_board)
          params.delete(:milestone_id)
          params.delete(:assignee_id)
          params.delete(:label_ids)
          params.delete(:weight)
          params.delete(:hide_backlog_list)
          params.delete(:hide_closed_list)
        end

        set_assignee
        set_milestone
        set_labels

        update_user_preferences_for(board) && super
      end

      private

      def update_user_preferences_for(board)
        preferences = params.delete(:preferences)

        return true unless preferences
        return true unless current_user

        ::Boards::UserPreferences::UpdateService.new(current_user, preferences).execute(board)
      end
    end
  end
end
