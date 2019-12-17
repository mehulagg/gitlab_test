# frozen_string_literal: true

module Geo
  module GitRepository
    class DeleteService
      def initialize(replicable_klass, replicable_id, handle, repository_path, repository_shard)
        @replicable_klass = replicable_klass.constantize
        @replicable_id = replicable_id
        @handle = handle
        @repository_path = repository_path
        @repository_shard = repository_shard
      end

      def execute
        GitalyClient.delete(repository_path, repository_shard) # fictional illustrative function call

        trackable.destroy!
      end

      private

      attr_accessor :replicable_klass, :replicable_id, :handle,
                    :repository_path, :repository_shard

      def blueprint
        @blueprint ||= replicable_klass.geo_blueprint(handle)
      end

      def trackable
        @trackable ||= blueprint.trackable.new(replicable_id)
      end

    end
  end
end
