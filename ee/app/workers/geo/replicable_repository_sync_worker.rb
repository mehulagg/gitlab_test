# frozen_string_literal: true

module Geo
  class ReplicableRepositorySyncWorker
    include ApplicationWorker
    include GeoQueue
    include Gitlab::Geo::LogHelpers

    sidekiq_options retry: 3, dead: false

    sidekiq_retry_in { |count| 30 * count }

    sidekiq_retries_exhausted do |msg, _|
      Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
    end

    def perform(registry_class_name, registry_id)
      ::Geo::ReplicableRepositorySyncService.new(registry_class_name, registry_id).execute
    end
  end
end
