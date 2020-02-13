# frozen_string_literal: true

module Geo
    class BlobVerificationPrimaryWorker
      include ApplicationWorker
      include GeoQueue
      include ::Gitlab::Geo::LogHelpers
      include ::Gitlab::Utils::StrongMemoize

      sidekiq_options retry: 3, dead: false

      def perform(blob_model, blob_id)
        replicator.calculate_checksum!
      rescue ActiveRecord::RecordNotFound
        log_error("Couldn't find the blob, skipping", blob_model: blob_model, blob_id: blob_id)
      end

      def replicator
        strong_memoize(:replicator) do
          model_record_id = payload['model_record_id']

          replicator_class = ::Gitlab::Geo::Replicator.for_replicable_name(replicable_name)
          replicator_class.new(model_record_id: model_record_id)
        end
      end
    end
  end
