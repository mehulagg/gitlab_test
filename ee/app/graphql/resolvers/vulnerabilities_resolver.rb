# frozen_string_literal: true

module Resolvers
  class VulnerabilitiesResolver < BaseResolver
    type Types::VulnerabilityType, null: true

    argument :severities, Types::VulnerabilitySeverityEnum,
             required: false,
             description: 'Only return vulnerabilities with these severities'

    def resolve(**args)
      # The project or group could have been loaded in batch by `BatchLoader`.
      # At this point we need the `id` of the project/group to query for boards, so
      # make sure it's loaded and not `nil` before continuing.
      parent = object.respond_to?(:sync) ? object.sync : object

      return Vulnerability.none unless parent

      if args[:severities]
        parent.vulnerabilities.where(severity: args[:severities])
      else
        parent.vulnerabilities
      end
    end
  end
end
