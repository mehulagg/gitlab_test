# frozen_string_literal: true

module Ci
  module ResourceGroups
    class ReleaseResourceFromBuildService < ::BaseService
      def execute(build)
        return error('This build does not retain a resource') unless build.retains_resource?

        unless build.resource_group.release_resource_from(build)
          return error('Failed to release a resource')
        end

        next_build = build.resource_group.waiting_build

        return success unless next_build

        result = Ci::ResourceGroups::RetainResourceForBuildService.new(next_build.project, next_build.user)
          .execute(next_build)

        if result[:status] == :success
          success(build: next_build)
        else
          error("Failed to retain a resource for the next build. #{result[:message]}")
        end
      end
    end
  end
end
