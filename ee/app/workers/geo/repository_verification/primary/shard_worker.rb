# frozen_string_literal: true

module Geo
  module RepositoryVerification
    module Primary
      class ShardWorker < Geo::Scheduler::Primary::SchedulerWorker
        sidekiq_options retry: false

        attr_accessor :shard_name

        def perform(shard_name)
          @shard_name = shard_name

          return unless Gitlab::ShardHealthCache.healthy_shard?(shard_name)

          super()
        end

        # We need a custom key here since we are running one worker per shard
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

        def schedule_job(project_id, repo_type)
          job_id = Geo::RepositoryVerification::Primary::SingleWorker.perform_async(project_id, repo_type)

          { id: project_id, repo_type: repo_type, job_id: job_id } if job_id
        end

        def finder
          @finder ||= Geo::RepositoryVerificationFinder.new(shard_name: shard_name)
        end

        def load_pending_resources
          resources = find_never_verified_resources(batch_size: db_retrieve_batch_size)
          remaining_capacity = db_retrieve_batch_size - resources.size
          return resources if remaining_capacity.zero?

          resources += find_recently_updated_resources(batch_size: remaining_capacity)
          remaining_capacity = db_retrieve_batch_size - resources.size
          return resources if remaining_capacity.zero?

          resources + find_resources_to_reverify(batch_size: remaining_capacity)
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def find_never_verified_resources(batch_size:)
          ids = finder.find_never_verified_projects(batch_size: batch_size).pluck(:id)
          ids.map { |id| [id, :all] }
        end
        # rubocop: enable CodeReuse/ActiveRecord

        # rubocop: disable CodeReuse/ActiveRecord
        def find_recently_updated_resources(batch_size:)
          repositories = finder.find_recently_updated_projects(:repository, batch_size: batch_size).pluck(:id)
          wikis = finder.find_recently_updated_projects(:wiki, batch_size: batch_size).pluck(:id)

          take_batch(
            repositories.map { |id| [id, :repository] },
            wikis.map { |id| [id, :wiki] },
            batch_size: batch_size
          )
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def find_resources_to_reverify(batch_size:)
          failed = find_failed_resources(batch_size: batch_size)
          reverifiable = find_reverifiable_resources(batch_size: batch_size)

          take_batch(failed, reverifiable, batch_size: batch_size)
        end

        def find_failed_resources(batch_size:)
          repositories = find_failed_repository_ids(batch_size: batch_size).map { |id| [id, :repository] }
          wikis = find_failed_wiki_ids(batch_size: batch_size).map { |id| [id, :wiki] }

          take_batch(repositories, wikis, batch_size: batch_size)
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def find_failed_repository_ids(batch_size:)
          finder.find_failed_repositories(batch_size: batch_size).pluck(:id)
        end
        # rubocop: enable CodeReuse/ActiveRecord

        # rubocop: disable CodeReuse/ActiveRecord
        def find_failed_wiki_ids(batch_size:)
          finder.find_failed_wikis(batch_size: batch_size).pluck(:id)
        end
        # rubocop: enable CodeReuse/ActiveRecord

        # rubocop: disable CodeReuse/ActiveRecord
        def find_reverifiable_resources(batch_size:)
          return [] unless reverification_enabled?

          jitter   = (minimum_reverification_interval.seconds * rand(15)) / 100
          interval = minimum_reverification_interval.ago + jitter.seconds

          repository_ids = finder.find_reverifiable_repositories(interval: interval, batch_size: batch_size).pluck(:id)
          wiki_ids = finder.find_reverifiable_wikis(interval: interval, batch_size: batch_size).pluck(:id)

          take_batch(
            repository_ids.map { |id| [id, :repository] },
            wiki_ids.map { |id| [id, :wiki] },
            batch_size: batch_size
          )
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def minimum_reverification_interval
          ::Gitlab::Geo.current_node.minimum_reverification_interval.days
        end

        def reverification_enabled?
          ::Feature.enabled?(:geo_repository_reverification, default_enabled: true)
        end
      end
    end
  end
end
