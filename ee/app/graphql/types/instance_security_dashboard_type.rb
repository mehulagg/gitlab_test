# frozen_string_literal: true

module Types
  class InstanceSecurityDashboardType < BaseObject
    graphql_name 'InstanceSecurityDashboard'
    description 'Represents an instance security dashboard'

    authorize :read_instance_security_dashboard

    field :vulnerabilities,
          ::Types::VulnerabilityType.connection_type,
          null: true,
          description: 'Vulnerabilities reported for projects on this instance security dashboard',
          resolver: Resolvers::VulnerabilitiesResolver,
          feature_flag: :first_class_vulnerabilities
  end
end
