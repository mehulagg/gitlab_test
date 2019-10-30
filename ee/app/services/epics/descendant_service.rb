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
        epic.base_and_descendants
      end
    end
  end
end
