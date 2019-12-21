# frozen_string_literal: true

module EE
  # Upload EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `Upload` model
  module Upload
    extend ActiveSupport::Concern

    prepended do
      include ::Gitlab::Geo::Replicator::ModelIntegration

      with_geo_replicator UploadReplicator

      after_destroy { replicator.publish :deleted }

      scope :for_model, ->(model) { where(model_id: model.id, model_type: model.class.name) }
      scope :syncable, -> { with_files_stored_locally }
    end
  end
end
