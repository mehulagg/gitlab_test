# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class Scan
          attr_reader :end_time, :start_time, :messages, :status, :type

          def initialize(params)
            @end_time = params.dig('end_time')
            @start_time = params.dig('start_time')
            @messages = params.dig('message')
            @status = params.dig('status')
            @type = params.dig('type')
            # https://gitlab.com/gitlab-org/gitlab/-/issues/235390
            # we can't add scan object here becuase we currently
            # don't support multuple scan objects which means
            # we will lose information when merging multiple reports
            @scanner = nil
          end
        end
      end
    end
  end
end
