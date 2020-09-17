# frozen_string_literal: true

module Boards
  module EpicUserPreferences
    class UpdateService < BaseService
      def initialize(user, board, epic_id, preferences = {})
        @current_user = user
        @board = board
        @epic_id = epic_id
        @preferences = preferences
      end

      def execute
        return error('User not set') unless current_user
        return error('Epic not found') unless epic = find_epic

        preference = Boards::EpicUserPreference.find_or_initialize_by(
          board_id: board.id, epic_id: epic.id, user_id: current_user.id)

        if preference.update(allowed_preferences)
          success(epic_user_preferences: preference)
        else
          error(preference.errors.to_sentence)
        end
      end

      private

      attr_accessor :current_user, :board, :epic_id, :preferences

      def find_epic
        epic = Epic.find(epic_id)
        return unless Ability.allowed?(current_user, :read_epic, epic)

        epic
      rescue ActiveRecord::RecordNotFound
        nil
      end

      def allowed_preferences
        preferences.slice(:collapsed)
      end
    end
  end
end
