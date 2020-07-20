# frozen_string_literal: true

module Gitlab
  module Ci
    class JobArtifactsExpirationQueue
      EXPIRE_ARTIFACTS_QUEUE = 'expire_ci_artifacts'

      class << self
        def push(data)
          Gitlab::Redis::SharedState.with do |redis|
            redis.zadd(EXPIRE_ARTIFACTS_QUEUE, data)
          end
        end

        def pop(size)
          Gitlab::Redis::SharedState.with do |redis|
            removable_count = redis
              .zrangebyscore(EXPIRE_ARTIFACTS_QUEUE, '-inf', Time.current.to_i, limit: [0, size])
              .size

            next unless removable_count > 0

            data = redis.zpopmin(EXPIRE_ARTIFACTS_QUEUE, removable_count)
            ids = removable_count > 1 ? data.map(&:first) : [data.first]
            yield(ids)
          end
        end

        def remove(data)
          Gitlab::Redis::SharedState.with do |redis|
            redis.zrem(EXPIRE_ARTIFACTS_QUEUE, data)
          end
        end

        def schedule_removal(records)
          data = Array(records).map { |record| [record.expire_at.to_i, record.id] }
          push(data)
        end

        def cancel_removal(records)
          data = Array(records).map(&:id)
          remove(data)
        end
      end
    end
  end
end
