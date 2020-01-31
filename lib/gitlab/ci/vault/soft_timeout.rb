# frozen_string_literal: true

module Gitlab
  module Ci
    module Vault
      class SoftTimeout
        TimeoutError = Class.new(StandardError)

        def self.with_deadline(timeout, &block)
          context = new(timeout)
          context.start
          yield(context)
        end

        def initialize(timeout)
          @timeout = timeout
        end

        def start
          @execution_deadline ||= current_monotonic_time + timeout.to_f
        end

        def check!
          raise TimeoutError if execution_expired?
        end

        def execution_expired?
          current_monotonic_time > execution_deadline
        end

        private

        attr_reader :execution_deadline, :timeout

        def current_monotonic_time
          Gitlab::Metrics::System.monotonic_time
        end
      end
    end
  end
end
