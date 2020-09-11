# frozen_string_literal: true

module Gitlab
  module Tracking
    class TestCasesParsed
      include Gitlab::Utils::UsageData

      EVENT_NAME = 'i_testing_test_case_parsed'
      HLL_BATCH_SIZE = 1000

      def initialize(build, test_suite)
        @build = build
        @test_suite = test_suite
      end

      def track_event
        test_case_hashes.each_slice(HLL_BATCH_SIZE) do |hashes|
          track_usage_event(EVENT_NAME, hashes)
        end
      end

      private

      attr_reader :build, :test_suite

      def test_case_hashes
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
