# frozen_string_literal: true

module Ci
  module Queueing
    class LegacyDatabaseMethod
      attr_reader :runner

      def initialize(runner)
        @runner = runner
      end

      def find
        builds = ::Ci::Queueing::FindMatchingJobs
          .new(runner.queueing_params)
          .execute

        valid = true

        found_build = builds.find do |build|
          case result = yield(build)
          when :success
            true
          when :conflict
            valid = false
            false
          when :skip
            false
          else
            raise ArgumentError, "invalid result: #{result}"
          end
        end

        if found_build
          Result.new(found_build, true)
        else
          Result.new(nil, valid)
        end
      end
    end
  end
end
