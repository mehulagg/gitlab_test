# frozen_string_literal: true

module Types
  class VulnerabilitiesSummaryType < BaseObject
    graphql_name 'VulnerabilitySummary'
    description 'Represents vulnerability counts by severity'

    authorize :read_vulnerability

    DEFAULT_SEVERITY_COUNT = 0
    VULNERABILITY_SEVERITIES = ::Vulnerabilities::Occurrence::SEVERITY_LEVELS.keys.freeze

    VULNERABILITY_SEVERITIES.each do |severity|
      field severity, GraphQL::INT_TYPE, null: true,
            description: "The number of vulnerabilities of #{severity.upcase} severity",
            resolve: -> (obj, _args, _ctx) { obj.public_send(severity) || 0 }
    end
  end
end
