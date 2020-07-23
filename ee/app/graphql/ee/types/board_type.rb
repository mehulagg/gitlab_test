# frozen_string_literal: true

module EE
  module Types
    module BoardType
      extend ActiveSupport::Concern

      prepended do
        field :weight, type: GraphQL::INT_TYPE, null: true,
              description: 'Weight of the board'

        field :user_preferences, type: ::Types::BoardUserPreferenceType, complexity: 5, null: true,
              description: 'User preferences for board.',
              resolve: -> (board, args, ctx) do
                board.preferences_for(ctx[:current_user])
              end
      end
    end
  end
end
