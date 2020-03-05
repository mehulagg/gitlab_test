# frozen_string_literal: true

module Gitlab
  module Experiments
    class Oj < Base
      def enabled?
        Feature.enabled?(:oj_json_dumping_experiment, default_enabled: true)
      end

      def publish(result)
        super

        histogram.observe(
          { method: "grape_default", matches: result.matched?, ignored: result.ignored? },
          result.control.duration
        )

        histogram.observe(
          { method: "oj", matches: result.matched?, ignored: result.ignored? },
          result.candidates.first.duration
        )
      end

      private

      def histogram
        @histogram ||= Gitlab::Metrics.histogram(
          :grape_json_dump_duration,
          "Time taken to dump an object to JSON"
        )
      end
    end
  end
end
