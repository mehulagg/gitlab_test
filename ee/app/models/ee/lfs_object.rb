# frozen_string_literal: true

module EE
  # LFS Object EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `LfsObject` model
  module LfsObject
    extend ActiveSupport::Concern

    STORE_COLUMN = :file_store

    prepended do
      include ObjectStorable
      include ::Gitlab::Geo::Replicator::ModelIntegration

      with_geo_replicator LfsObjectReplicator

      after_destroy { replicator.publish :deleted }

      scope :project_id_in, ->(ids) { joins(:projects).merge(::Project.id_in(ids)) }
    end
  end
end
