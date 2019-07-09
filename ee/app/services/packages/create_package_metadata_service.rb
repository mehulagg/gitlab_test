# frozen_string_literal: true
module Packages
  class CreatePackageMetadataService < BaseService
    attr_reader :package, :metadata

    def initialize(package, metadata)
      @package = package
      @metadata = metadata
    end

    def execute
      package.create_package_metadatum(metadata: metadata)
    end
  end
end
