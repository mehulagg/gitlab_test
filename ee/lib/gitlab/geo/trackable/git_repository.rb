# frozen_string_literal: true

module Gitlab
  module Geo
    module Trackable
      class GitRepository
        attr_accessor :registry

        delegate :state, :retry_count, :last_sync_failure,
                 :retry_at, :last_sync_at,
                 to: :registry

        delegate :repository_path, :repository_shard,
                 to: :replicable

        def initialize(replicable_id)
          @registry = Geo::Tracking::GitRepositoryRegistry.safe_find_or_create_by(replicable_id: replicable_id)
        end

        def destroy!
          registry.destroy!

          registry = nil
        end

        private

        def replicable
          @replicable ||= Something.find(registry.replicable_id)
        end
      end
    end
  end
end
