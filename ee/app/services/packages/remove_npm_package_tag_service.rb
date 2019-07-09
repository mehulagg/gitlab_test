# frozen_string_literal: true
module Packages
  class RemoveNpmPackageTagService < BaseService
    attr_reader :project, :package_tag

    def initialize(package_tag)
      @package_tag = package_tag
    end

    def execute
      package_tag.destroy
    end
  end
end
