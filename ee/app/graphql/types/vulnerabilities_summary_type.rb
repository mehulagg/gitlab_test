# frozen_string_literal: true

module Types
  class VulnerabilitiesSummaryType < BaseObject
    DEFAULT_SEVERITY_COUNT = 0
    VULNERABILITY_SEVERITIES = ::Vulnerabilities::Occurrence::SEVERITY_LEVELS.keys.freeze

    VULNERABILITY_SEVERITIES.each do |severity|
      field severity, GraphQL::INT_TYPE, null: true,
            description: "The number of vulnerabilities of #{severity.upcase} severity",
            resolve: -> (obj, _args, _ctx) { obj.fetch(severity, DEFAULT_SEVERITY_COUNT) }
    end
  end
end
