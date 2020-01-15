# frozen_string_literal: true

module Gitlab
  module ValueStreamAnalytics
    class StagingEventFetcher < BaseEventFetcher
      include ProductionHelper
      include BuildsEventHelper
    end
  end
end
