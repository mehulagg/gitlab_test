# frozen_string_literal: true

module Geo
  module Verification
    module Secondary
      class SchedulerWorker < Geo::Scheduler::Secondary::PerShardSchedulerWorker
        def perform
          # TODO: move this check downstream
          # return unless Gitlab::Geo.repository_verification_enabled?

          super
        end

        def schedule_job(shard_name)
          Geo::Verification::Secondary::ShardWorker.perform_async(shard_name)
        end
      end
    end
  end
end
