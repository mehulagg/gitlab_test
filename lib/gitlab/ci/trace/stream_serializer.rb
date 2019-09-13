# frozen_string_literal: true

module Gitlab
  module Ci
    class Trace
      class StreamSerializer
        def initialize(stream, build)
          @stream = stream
          @build = build
        end

        def serialize(content_format:, state:)
          result = {
            id: @build.id,
            status: @build.status,
            complete: @build.complete?
          }

          if @stream.valid?
            @stream.limit

            trace = build_trace(content_format, state)

            result.merge!(trace.to_h)
          end

          result
        end

        private

        def build_trace(content_format, state)
          case content_format
          when :json
            @stream.json_with_state(state)
          when :html
            @stream.html_with_state(state)
          else
            raise ArgumentError, "Unknown content_format '#{content_format}'"
          end
        end
      end
    end
  end
end
