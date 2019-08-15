module Packages
  class CreatePackageMetadataService < BaseService
    attr_reader :package, :params

    def initialize(package, params)
      @package = package
      @params = params
    end

    def execute
      package.update!(
          package_metadatum_attributes: params
      )
    end
  end
end
