# frozen_string_literal: true

module Packages
  module Conan
    class FindOrCreatePackageService < BaseService
      def execute
        package = ::Packages::ConanPackageFinder
                    .new(current_user, recipe: params[:recipe], project: project).execute

        unless package
          package_params = {
            name: params[:recipe],
            path: params[:path],
            version: params[:recipe_path].split('/')[1]
          }

          package = ::Packages::Conan::CreatePackageService
                      .new(project, current_user, package_params).execute
        end

        package
      end
    end
  end
end
