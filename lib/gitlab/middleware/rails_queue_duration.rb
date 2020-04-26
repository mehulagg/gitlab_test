# frozen_string_literal: true

# This Rack middleware is intended to measure the latency between
# gitlab-workhorse forwarding a request to the Rails application and the
# time this middleware is reached.

require "pp"

module Gitlab
  module Middleware
    class RailsQueueDuration
      GITLAB_RAILS_QUEUE_DURATION_KEY = 'GITLAB_RAILS_QUEUE_DURATION'

      class StatTracker
        class Stat
          def initialize(key)
            @key = key
            @sum = Hash.new(0)
          end

          def start
            @stat = RubyVM.stat
          end

          def stop
            return unless @stat

            diff = RubyVM.stat
              .merge(@stat) { |_, o, n| o - n }
              .reject { |_, v| v == 0 }

            return if diff.empty?

            diff.each { |k, v| @sum[k] += v }

            p @key => diff

            @stat = nil
          end

          def empty?
            @sum.empty?
          end

          def weight
            @weight ||= @sum.values.max || 0
          end

          def to_s
            @sum.to_s
          end
        end

        def self.track(every: 5, &block)
          stats = {}
          amount = -1
          total = 0
          do_track = false

          trace = TracePoint.new(:call, :return) do |tp|

            if !do_track && tp.path.match?(/gdk-ee/)
              do_track = true
            end

            next unless do_track

            total += 1

            puts total: total if total % 1000 == 0

            case tp.event
            when :call
              amount += 1
              next unless amount % every == 0
              x = "#{tp.path}:#{tp.lineno}:#{tp.defined_class}##{tp.method_id}"
              key = "#{tp.path}:#{tp.defined_class.name}##{tp.method_id}"
              stats[key] ||= Stat.new(x)
              stats[key].start
            when :return
              key = "#{tp.path}:#{tp.defined_class.name}##{tp.method_id}"
              stats[key]&.stop
            end
          end

          puts total: total

          trace.enable(&block)
        end
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        stat = RubyVM.stat
        trans = Gitlab::Metrics.current_transaction
        proxy_start = env['HTTP_GITLAB_WORKHORSE_PROXY_START'].presence
        if trans && proxy_start
          # Time in milliseconds since gitlab-workhorse started the request
          duration = Time.now.to_f * 1_000 - proxy_start.to_f / 1_000_000
          trans.set(:rails_queue_duration, duration)

          duration_s = Gitlab::Utils.ms_to_round_sec(duration)
          metric_rails_queue_duration_seconds.observe(trans.labels, duration_s)
          env[GITLAB_RAILS_QUEUE_DURATION_KEY] = duration_s
        end

        request = Rack::Request.new(env)
        if every = request.params['rubyvm']
          StatTracker.track(every: every.to_i) { @app.call(env) }
        else
          @app.call(env)
        end

      ensure
        diff = RubyVM.stat.merge(stat) { |_, o, n| o - n }.reject { |_, v| v == 0 }
        puts diff if diff.any?
      end

      private

      def metric_rails_queue_duration_seconds
        @metric_rails_queue_duration_seconds ||= Gitlab::Metrics.histogram(
          :gitlab_rails_queue_duration_seconds,
          'Measures latency between GitLab Workhorse forwarding a request to Rails',
          Gitlab::Metrics::Transaction::BASE_LABELS
        )
      end
    end
  end
end
