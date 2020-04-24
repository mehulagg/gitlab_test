# frozen_string_literal: true

module EE
  module Milestoneable
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    override :milestone_available?
    def milestone_available?
      # This is to avoid attempting to set milestone_id in an Epic to nil, which would cause an exception
      # as Epic doesn't have milestone_id
      return true if is_a?(Epic)

      super
    end

    override :sprint_available?
    def sprint_available?
      # This is to avoid attempting to set sprint_id in an Epic to nil, which would cause an exception
      # as Epic doesn't have sprint_id
      return true if is_a?(Epic)

      super
    end

    override :supports_milestone?
    def supports_milestone?
      super && !is_a?(Epic)
    end
  end
end
