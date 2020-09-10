# frozen_string_literal: true

module Gitlab
  module Tracking
    class TestCasesParsed
      EVENT_NAME = 'test_case_parsed'
      HLL_BATCH_SIZE = 1000

      class << self
        def track_event(build, test_suite)
          test_case_hashes(build, test_suite).each_slice(HLL_BATCH_SIZE) do |hashes|
            Gitlab::UsageDataCounters::HLLRedisCounter.track_event(hashes, EVENT_NAME)
          end
        end

        private

        def test_case_hashes(build, test_suite)
          [].tap do |hashes|
            test_suite.each_test_case do |test_case|
              key = "#{build.project_id}-#{test_suite.name}-#{test_case.key}"
              hashes << Digest::SHA256.hexdigest(key)
            end
          end
        end
      end
    end
  end
end
