# frozen_string_literal: true

module Geo
  module GitRepository
    class DeleteWorker
      include GeoQueue
      include Gitlab::Geo::LogHelpers

      def perform(json)
        ::Geo::GitRepository::DeleteService.new(json[:replicable_klass],
                                                json[:replicable_id],
                                                json[:handle]
                                                json[:repository_path],
                                                json[:repository_shard]).execute
      end
    end
  end
end
