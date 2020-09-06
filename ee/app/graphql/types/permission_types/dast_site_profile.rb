# frozen_string_literal: true

module Types
  module PermissionTypes
    class DastSiteProfile < BasePermissionType
      graphql_name 'DastSiteProfilePermissions'
      description 'Check permissions for the current user on site profile'

      abilities :manage_on_demand_dast_scans
    end
  end
end
