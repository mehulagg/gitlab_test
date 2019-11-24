# frozen_string_literal: true

class Geo::DesignRegistry < Geo::BaseRegistry
  include ::Gitlab::Geo::Replicable::Strategies::Repository::Registry

  belongs_to :project

  def self.foreign_key
    :project_id
  end

  def self.skippable?
    Feature.disabled?(:enable_geo_design_sync)
  end

  def self.sync_service_class
    Geo::DesignRepositorySyncService
  end

  def replicable
    project.design_repository
  end

  def enqueue_sync
    # TODO Introduce ::Geo::RepositorySyncWorker.perform_async(self.class.name, self.id)
    # so we can move this method to the Strategy
    ::Geo::DesignRepositorySyncWorker.perform_async(project_id)
  end
end
