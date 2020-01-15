# frozen_string_literal: true

module Gitlab
  module ValueStreamAnalytics
    module Stage
      def self.[](stage_name)
        ValueStreamAnalytics.const_get("#{stage_name.to_s.camelize}Stage", false)
      end
    end
  end
end
