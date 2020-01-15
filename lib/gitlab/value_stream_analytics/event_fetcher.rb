# frozen_string_literal: true

module Gitlab
  module ValueStreamAnalytics
    module EventFetcher
      def self.[](stage_name)
        ValueStreamAnalytics.const_get("#{stage_name.to_s.camelize}EventFetcher", false)
      end
    end
  end
end
