# frozen_string_literal: true
module Packages
  class CreateNpmPackageTagService < BaseService
    attr_reader :package, :tag

    def initialize(package, tag)
      @package = package
      @tag = tag
    end

    def execute
      packages = Packages::PackageTag.with_tag_name_and_package_name(tag, package.name)
      if packages.present?
        update_tag(packages.last)
      else
        package.package_tags.create(name: tag)
      end
    end

    private

    def update_tag(package_tag)
      package_tag.update!(package_id: package.id)
    end
  end
end
