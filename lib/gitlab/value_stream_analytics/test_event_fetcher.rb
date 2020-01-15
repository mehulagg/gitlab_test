# frozen_string_literal: true

module Gitlab
  module ValueStreamAnalytics
    class TestEventFetcher < BaseEventFetcher
      include TestHelper
      include BuildsEventHelper
    end
  end
end
