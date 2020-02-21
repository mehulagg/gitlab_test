# frozen_string_literal: true

module Resolvers
  class BoardListsResolver < BaseResolver
    type Types::BoardListType, null: true

    def resolve(**args)
      # The project or group could have been loaded in batch by `BatchLoader`.
      # At this point we need the `id` of the project/group to query for boards, so
      # make sure it's loaded and not `nil` before continuing.
      board = object.respond_to?(:sync) ? object.sync : object

      return List.none unless board

      board.destroyable_lists
    end
  end
end
