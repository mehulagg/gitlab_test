# frozen_string_literal: true

module Epics
  class DescendantService
    include Gitlab::Utils::StrongMemoize

    def initialize(epic, current_user)
      @epic = epic
      @current_user = current_user
    end

    private

    attr_reader :epic, :current_user

    def accessible_epics
      strong_memoize(:epics) do
        epics = epic.base_and_descendants
        epic_groups = Group.for_epics(epics)
        groups = Group.groups_user_can_read_epics(epic_groups, current_user, same_root: true)
        epics.in_selected_groups(groups)
      end
    end
  end
end
