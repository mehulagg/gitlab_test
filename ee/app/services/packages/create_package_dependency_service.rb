# frozen_string_literal: true
module Packages
  class CreatePackageDependencyService < BaseService
    METADATA_KEYS = %i(dependencies devDependencies bundleDependencies peerDependencies deprecated).freeze

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
          package_dependency = package.package_dependencies.find_or_create_by_version_pattern(pkg_dependency[0], pkg_dependency[1])
          package.package_dependency_links.find_or_create_by_dependency_type(package_dependency.id, type)
        end
      end
    end

    attr_reader :package, :dependencies
  end
end
