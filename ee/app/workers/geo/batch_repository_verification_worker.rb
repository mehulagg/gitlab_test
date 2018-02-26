module Geo
  class BatchRepositoryVerificationWorker
    include ApplicationWorker
    include CronjobQueue
    include ExclusiveLeaseGuard
    include Gitlab::Geo::LogHelpers

    BATCH_SIZE     = 1000
    DELAY_INTERVAL = 5.minutes.to_i
    LEASE_TIMEOUT  = 1.hour.to_i

    def perform(recently_updated = true)
      return unless Gitlab::Geo.primary?

      try_obtain_lease do
        outdated_projects = projects(recently_updated: recently_updated)

        outdated_projects.each_batch(of: BATCH_SIZE, column: :last_repository_updated_at) do |batch, index|
          interval = index * DELAY_INTERVAL

          batch.each do |project|
            Geo::SingleRepositoryVerificationWorker.perform_in(interval, project.id)
          end
        end
      end
    end

    private

    def projects(recently_updated:)
      relation =
        Project.select(:id)
         .joins(left_join_repository_state)
         .where(repository_verification_outdated.or(wiki_verification_outdated).or(repository_never_verified))

      relation = relation.where(repository_recently_updated) if recently_updated

      relation.order(repository_state_table[:id].desc)
    end

    def projects_table
      Project.arel_table
    end

    def repository_state_table
      ProjectRepositoryState.arel_table
    end

    def left_join_repository_state
      projects_table
        .join(repository_state_table, Arel::Nodes::OuterJoin)
        .on(projects_table[:id].eq(repository_state_table[:project_id]))
        .join_sources
    end

    def repository_verification_outdated
      repository_state_table[:last_repository_verification_at]
        .lt(projects_table[:last_repository_updated_at])
    end

    def wiki_verification_outdated
      repository_state_table[:last_wiki_verification_at]
        .lt(projects_table[:last_repository_updated_at])
    end

    def repository_never_verified
      repository_state_table[:id].eq(nil)
    end

    def repository_recently_updated
      projects_table[:last_repository_updated_at].gteq(24.hours.ago)
    end

    def lease_timeout
      LEASE_TIMEOUT
    end
  end
end
