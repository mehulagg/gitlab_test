# frozen_string_literal: true

module Gitlab
  module Metrics
    # Rack middleware for tracking Redis metrics from Grape and Web requests.
    class RailsRedisMiddleware
      LABELS = [:controller, :action].freeze

      def initialize(app)
        @app = app
      end

      def call(env)
        transaction = Gitlab::Metrics.current_transaction

        @app.call(env)
      ensure
        record_metrics(transaction) if transaction
      end

      private

      def record_metrics(transaction)
        labels = transaction.labels.slice(*LABELS)
        query_time = Gitlab::Instrumentation::Redis.query_time
        request_count = Gitlab::Instrumentation::Redis.get_request_count

        Gitlab::Metrics
          .counter(:rails_redis_requests_total, 'Redis requests count')
          .increment(labels, request_count)

        Gitlab::Metrics
          .histogram(:rails_redis_requests_duration_seconds, 'Redis requests count', {}, Gitlab::Instrumentation::Redis::QUERY_TIME_BUCKETS)
          .observe(labels, query_time)
      end
    end
  end
end
