# frozen_string_literal: true

require "scientist"
require "scientist/experiment"

module Gitlab
  module Experiments
    class Base
      include Scientist::Experiment

      attr_accessor :name

      def initialize(name)
        @name = name
      end

      def publish(result)
        # By default log results

        log = "Experiment `#{name}`: "
        log += "Control: #{result.control.duration}s, "

        candidates = result.candidates.each_with_index.map do |candidate, index|
          "Candidate #{index}: #{candidate.duration}s"
        end

        log += candidates.join(", ")

        Rails.logger.info(log)
      end
    end
  end
end
