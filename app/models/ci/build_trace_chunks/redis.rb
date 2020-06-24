# frozen_string_literal: true

module Ci
  module BuildTraceChunks
    class Redis
      CHUNK_REDIS_TTL = 1.week

      def available?
        true
      end

      # TODO / Grzegorz: sequence diagram for writing a chunk with all the
      # Redis communication required
      def data(model)
        Gitlab::Redis::SharedState.with do |redis|
          redis.get(key(model))
        end
      end

      def set_data(model, data)
        Gitlab::Redis::SharedState.with do |redis|
          redis.set(key(model), data, ex: CHUNK_REDIS_TTL)
        end
      end

      def delete_data(model)
        delete_keys([[model.build_id, model.chunk_index]])
      end

      def keys(relation)
        relation.pluck(:build_id, :chunk_index)
      end

      def delete_keys(keys)
        return if keys.empty?

        keys = keys.map { |key| key_raw(*key) }

        # TODO / Grzegorz: this is a multi key operation, is there a way to do
        # that in a more redis cluster friendly way? We can probably fix that.
        Gitlab::Redis::SharedState.with do |redis|
          redis.del(keys)
        end
      end

      private

      def key(model)
        key_raw(model.build_id, model.chunk_index)
      end

      def key_raw(build_id, chunk_index)
        "gitlab:ci:trace:#{build_id.to_i}:chunks:#{chunk_index.to_i}"
      end
    end
  end
end
