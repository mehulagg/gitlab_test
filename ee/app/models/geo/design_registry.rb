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
    Geo::ReplicableRepositorySyncService
  end

  def replicable
    project.design_repository
  end

  def replicable_human_name
    'design repository'
  end

  def repo_type
    :design
  end
end
