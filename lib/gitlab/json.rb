# frozen_string_literal: true

module Gitlab
  module Json
    INVALID_LEGACY_TYPES = [String, TrueClass, FalseClass].freeze

    class << self
      def parse(string, *args, **named_args)
        legacy_mode = legacy_mode_enabled?(named_args.delete(:legacy_mode))

        data = benchmark(method: "parse") do
          adapter.parse(string, *args, **named_args)
        end

        handle_legacy_mode!(data) if legacy_mode

        data
      end

      def parse!(string, *args, **named_args)
        legacy_mode = legacy_mode_enabled?(named_args.delete(:legacy_mode))

        data = benchmark(method: "parse!") do
          adapter.parse!(string, *args, **named_args)
        end

        handle_legacy_mode!(data) if legacy_mode

        data
      end

      def dump(*args)
        benchmark(method: "dump") do
          adapter.dump(*args)
        end
      end

      def generate(*args)
        puts args

        benchmark(method: "generate") do
          puts args
          adapter.generate(*args)
        end
      end

      def pretty_generate(*args)
        puts args

        benchmark(method: "pretty_generate") do
          puts args
          adapter.pretty_generate(*args)
        end
      end

      private

      def adapter
        ::JSON
      end

      def parser_error
        ::JSON::ParserError
      end

      def legacy_mode_enabled?(arg_value)
        arg_value.nil? ? false : arg_value
      end

      def handle_legacy_mode!(data)
        return data unless Feature.enabled?(:json_wrapper_legacy_mode, default_enabled: true)

        raise parser_error if INVALID_LEGACY_TYPES.any? { |type| data.is_a?(type) }
      end

      def histogram
        @histogram ||= Gitlab::Metrics.histogram(
          :gitlab_json_seconds,
          "Measurement of time spent processing JSON in Ruby"
        )
      end

      def benchmark(opts = {}, &block)
        opts = { processor: adapter.to_s }.merge(opts)
        puts opts
        return_value = nil

        time = Benchmark.realtime do
          return_value = block.call
        end

        puts time

        histogram.observe(opts, time)

        return_value
      end
    end
  end
end
