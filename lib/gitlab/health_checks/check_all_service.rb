# frozen_string_literal: true

module Gitlab::HealthChecks
  class CheckAllService
    CHECKS = [
      Gitlab::HealthChecks::DbCheck,
      Gitlab::HealthChecks::Redis::RedisCheck,
      Gitlab::HealthChecks::Redis::CacheCheck,
      Gitlab::HealthChecks::Redis::QueuesCheck,
      Gitlab::HealthChecks::Redis::SharedStateCheck,
      Gitlab::HealthChecks::GitalyCheck
    ].freeze

    # Returns a collection of Gitlab::HealthChecks::Result.
    def readiness
      results = CHECKS.map { |check| [check.name, check.readiness] }

      results = flatten_results(results)

      log_results(results)

      results
    end

    # Returns a collection of Gitlab::HealthChecks::Result.
    def liveness
      results = CHECKS.map { |check| [check.name, check.liveness] }

      results = flatten_results(results)

      log_results(results)

      results
    end

    # Returns true if all liveness checks pass, and false if at least one fails.
    def liveness?
      liveness.all? { |name, result| result.success }
    end

    private

    # Returns a collection of Gitlab::HealthChecks::Result.
    #
    # This method is necessary because an individual check may return
    # Gitlab::HealthChecks::Result, or it may return a collection of
    # Gitlab::HealthChecks::Result.
    def flatten_results(results)
      results.flat_map do |name, result|
        if result.is_a?(Gitlab::HealthChecks::Result)
          [[name, result]]
        else
          result.map { |r| [name, r] }
        end
      end
    end

    def log_results(results)
      results.each do |name, result|
        if result.success
          Rails.logger.debug("Health check successful: #{{ name: name, message: result.message, labels: result.labels }}")
        else
          Rails.logger.error("Health check failed: #{{ name: name, message: result.message, labels: result.labels }}")
        end
      end
    end
  end
end
