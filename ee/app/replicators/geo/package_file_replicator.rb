# frozen_string_literal: true

module Geo
  class PackageFileReplicator < Gitlab::Geo::Replicator
    include ::Geo::BlobReplicatorStrategy

    def self.model
      ::Packages::PackageFile
    end

    def carrierwave_uploader
      model_record.file
    end

    def self.replication_enabled_by_default?
      false
    end
  end
end
