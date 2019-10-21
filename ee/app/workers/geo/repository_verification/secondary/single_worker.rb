# frozen_string_literal: true

module Geo
  module RepositoryVerification
    module Secondary
      class SingleWorker
        include ApplicationWorker
        include GeoQueue
        include ExclusiveLeaseGuard
        include Gitlab::Geo::ProjectLogHelpers

        sidekiq_options retry: false

        LEASE_TIMEOUT = 1.hour.to_i

        attr_reader :registry
        private     :registry

        delegate :project, to: :registry

        # rubocop: disable CodeReuse/ActiveRecord
        def perform(registry_id, repo_type)
          return unless Gitlab::Geo.secondary?

          @registry = Geo::ProjectRegistry.find_by(id: registry_id)
          return if registry.nil? || project.nil? || project.pending_delete?

          repo_type = repo_type.to_sym

          try_obtain_lease do
            if [:repository, :all].include? repo_type
              Geo::RepositoryVerificationSecondaryService.new(registry).execute
            end
            if [:wiki, :all].include? repo_type
              Geo::WikiVerificationSecondaryService.new(registry).execute
            end
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        private

        def lease_key
          "geo:repository_verification:secondary:single_worker:#{project.id}"
        end

        def lease_timeout
          LEASE_TIMEOUT
        end
      end
    end
  end
end
