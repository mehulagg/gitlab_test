# frozen_string_literal: true

module EE
  module Ci
    module Queueing
      module Params
        extend ActiveSupport::Concern

        # additional visibility levels outside of quota
        attr_accessor :visibility_levels_without_minutes_quota
      end
    end
  end
end
