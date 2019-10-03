# frozen_string_literal: true
module Packages
  class CreatePackageDependencyService < BaseService
    METADATA_KEYS = %i(dependencies devDependencies bundleDependencies peerDependencies, deprecated).freeze

    def initialize(package, dependencies)
      @package = package
      @dependencies = dependencies
    end

    def execute
      METADATA_KEYS.each do |type|
        create_dependency(type)
      end
    end

    private

    def create_dependency(type)
      if dependencies[type].present?
        dependencies[type].each do |pkg_dependency|
          package_dependency = package.package_dependencies.find_or_create(name: pkg_dependency[0], version_pattern: pkg_dependency[1])
          package.package_dependency_links.create(package_dependency_id: package_dependency.id, dependency_type: type)
        end
      end
    end

    attr_reader :package, :dependencies
  end
end
