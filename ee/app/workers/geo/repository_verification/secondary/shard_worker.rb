# frozen_string_literal: true

module Geo
  module RepositoryVerification
    module Secondary
      class ShardWorker < Geo::Scheduler::Secondary::SchedulerWorker
        include CronjobQueue
        attr_accessor :shard_name

        def perform(shard_name)
          @shard_name = shard_name

          return unless Gitlab::ShardHealthCache.healthy_shard?(shard_name)

          super()
        end

        def lease_key
          @lease_key ||= "#{self.class.name.underscore}:shard:#{shard_name}"
        end

        private

        def skip_cache_key
          "#{self.class.name.underscore}:shard:#{shard_name}:skip"
        end

        def worker_metadata
          { shard: shard_name }
        end

        def max_capacity
          current_node.verification_max_capacity
        end

        def load_pending_resources
          finder = Geo::ProjectRegistryPendingVerificationFinder
            .new(current_node: current_node, shard_name: shard_name, batch_size: db_retrieve_batch_size)

          repositories = finder.repositories.pluck_primary_key
          wikis = finder.wikis.pluck_primary_key

          take_batch(
            repositories.map { |id| [id, :repository] },
            wikis.map { |id| [id, :wiki] },
            batch_size: db_retrieve_batch_size
          )
        end

        def schedule_job(registry_id, repo_type)
          job_id = Geo::RepositoryVerification::Secondary::SingleWorker.perform_async(registry_id)

          { id: registry_id, repo_type: repo_type, job_id: job_id } if job_id
        end
      end
    end
  end
end
