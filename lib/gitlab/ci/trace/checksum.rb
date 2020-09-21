# frozen_string_literal: true

module Gitlab
  module Ci
    class Trace
      class Checksum
        include Gitlab::Utils::StrongMemoize

        attr_reader :build

        def initialize(build)
          @build = build
        end

        def valid?
          return false unless state_crc32 > 0

          state_crc32 == chunks_crc32
        end

        def state_crc32
          strong_memoize(:crc32) do
            build.pending_state&.trace_checksum.then do |checksum|
              checksum.to_s.split('crc32:').last.to_i
            end
          end
        end

        def chunks_crc32
          persisted_trace_chunks.reduce(0) do |crc32, chunk|
            Zlib.crc32_combine(crc32, chunk.crc32, chunk_size(chunk))
          end
        end

        def chunks_count
          strong_memoize(:chunks_count) do
            build.trace_chunks.maximum(:chunk_index)
          end
        end

        private

        def chunk_size(chunk)
          if chunk.chunk_index == chunks_count
            chunk.size
          else
            ::Ci::BuildTraceChunk::CHUNK_SIZE
          end
        end

        def persisted_trace_chunks
          # TODO do not load raw_data!
          build.trace_chunks.persisted
        end
      end
    end
  end
end
