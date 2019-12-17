# frozen_string_literal: true

module Geo
  module GitRepository
    class SyncWorker
      include GeoQueue
      include Gitlab::Geo::LogHelpers

      def perform(json)
        ::Geo::GitRepository::SyncService.new(json[:replicable_klass],
                                              json[:replicable_id],
                                              json[:handle]).execute
      end
    end
  end
end
