# frozen_string_literal: true
module Packages
  class CreatePackageMetadataService < BaseService

    def initialize(package, metadata)
      @package = package
      @metadata = metadata
    end

    def execute
      package.create_package_metadatum(metadata: metadata)
    end

    private

    attr_reader :package, :metadata

  end
end
