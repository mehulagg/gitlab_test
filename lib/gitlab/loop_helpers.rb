# frozen_string_literal: true

module Gitlab
  module LoopHelpers
    ##
    # This helper method repeats the same task until it's expired.
    #
    # Note: ExpiredLoopError does not happen until the given block finished.
    #       Please do not use this method for heavy or asynchronous operations.
    def loop_until(timeout: nil, limit: 1_000_000)
      raise ArgumentError unless limit
      return enum_for(:loop_until, timeout: timeout, limit: limit) unless block_given?

      start = Gitlab::Metrics::System.monotonic_time

      limit.times do |index|
        return true unless yield(index)

        return false if timeout && (Gitlab::Metrics::System.monotonic_time - start) > timeout
      end

      false
    end
  end
end
