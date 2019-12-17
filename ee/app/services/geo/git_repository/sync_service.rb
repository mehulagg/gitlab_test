# frozen_string_literal: true

module Geo
  module GitRepository
    class SyncService
      def initialize(replicable_klass, replicable_id, handle)
        @replicable_klass = replicable_klass.constantize
        @replicable_id = replicable_id
        @handle = handle
      end

      def execute
        GitalyClient.fetch_remote(trackable.repository_path, trackable.repository_shard) # fictional illustrative function call

        trackable.synced!
      end

      private

      attr_accessor :replicable_klass, :replicable_id, :handle

      def blueprint
        @blueprint ||= replicable_klass.geo_blueprint(handle)
      end

      def replicable
        @replicable ||= replicable_klass.find(replicable_id)
      end

      def trackable
        @trackable ||= blueprint.trackable.new(replicable_id)
      end
    end
  end
end
