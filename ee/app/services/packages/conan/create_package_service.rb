# frozen_string_literal: true

module Packages
  module Conan
    class CreatePackageService < BaseService
      def execute
        project.packages.create!(
          name: params[:name],
          version: params[:version],
          package_type: :conan
        )
      end
    end
  end
end
