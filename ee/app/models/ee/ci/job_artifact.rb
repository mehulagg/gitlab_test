module EE
  # CI::JobArtifact EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `Ci::JobArtifact` model
  module Ci::JobArtifact
    extend ActiveSupport::Concern

    prepended do
      after_destroy :log_geo_event

      scope :with_files_stored_locally, -> { where(file_store: [nil, JobArtifactUploader::LOCAL_STORE]) }
    end

    def local_store?
      [nil, JobArtifactUploader::LOCAL_STORE].include?(self.file_store)
    end

    private

    def log_geo_event
      ::Geo::JobArtifactDeletedEventStore.new(self).create
    end
  end
end
