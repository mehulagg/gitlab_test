# frozen_string_literal: true

module Geo
  module Replicable
    extend ActiveSupport::Concern

    included do
      @@geo_blueprints = {}
    end

    class_methods do
      def geo_replicable(handle, &block)
        blueprint = ::Gitlab::Geo::Blueprint.new
        blueprint.workable_type = :git_repository # TODO only type of workable supported atm

        yield blueprint

        @@geo_blueprints[handle] = blueprint
      end

      def geo_blueprint(handle)
        @@geo_blueprints[handle]
      end
    end

    def geo_updated!(handle)
      blueprint = self.class.geo_blueprint(handle)

      ::Geo::JsonEvent.create!(trackable_klass: self.class, trackable_id: self.id, handle: handle,
                               workable_type: blueprint.workable_type, workable_event: :updated)
    end

    def geo_deleted!(handle)
      blueprint = self.class.geo_blueprint(handle)

      ::Geo::JsonEvent.create!(trackable_klass: self.class, trackable_id: self.id, handle: handle,
                               workable_type: blueprint.workable_type, workable_event: :deleted,
                               repository_path: blueprint.repository_path, repository_shard: blueprint.repository_shard)
    end
  end
end
