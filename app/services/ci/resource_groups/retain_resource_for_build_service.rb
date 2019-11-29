# frozen_string_literal: true

module Ci
  module ResourceGroups
    class RetainResourceForBuildService < ::BaseService
      def execute(build)
        return error('This build does not require a resource') unless build.requires_resource?

        unless build.resource_group.retain_resource_for(build)
          return error('Failed to retain a resource')
        end

        build.reset.enqueue ? success : error('Failed to enqueue')
      end
    end
  end
end
