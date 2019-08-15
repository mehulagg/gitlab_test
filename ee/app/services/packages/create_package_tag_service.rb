module Packages

  class CreateNpmPackageTagService < BaseService
    attr_reader :package, :package_tags, :tag

    def initialize(package, package_tags, tag)
      @package = package
      @package_tags = package_tags
      @tag = tag
    end

    def execute
      package_tags.empty? ? package.package_tags.create(name: tag, project_id: package.project_id) : create_or_update_tag
    end

    def create_or_update_tag
      package_tags.each do |package_tag|
        return if package_tag.name != tag
        package_tag.update!(package_id: package.id)
      end

    end

  end

end
