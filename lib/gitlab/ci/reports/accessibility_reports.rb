# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class AccessibilityReports
        attr_accessor :urls, :total, :passes, :errors

        def initialize
          @urls = {}
          @total = 0
          @passes = 0
          @errors = 0
        end

        def add_url(url, data)
          urls[url] = data
        end
      end
    end
  end
end
