# frozen_string_literal: true

module Geo
  class BlobVerificationPrimaryWorker
    include ApplicationWorker
    include GeoQueue
    include ::Gitlab::Geo::LogHelpers

    sidekiq_options retry: 3, dead: false

    idempotent!

    def perform(replicable_name, replicable_id)
      replicator = ::Gitlab::Geo::Replicator.for_replicable_params(replicable_name: replicable_name, replicable_id: replicable_id)

      replicator.calculate_checksum!
    rescue ActiveRecord::RecordNotFound
      log_error("Couldn't find the blob, skipping", replicable_name: replicable_name, replicable_id: replicable_id)
    end
  end
end
