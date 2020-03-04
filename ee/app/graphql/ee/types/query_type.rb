# frozen_string_literal: true

module EE
  module Types
    module QueryType
      extend ActiveSupport::Concern

      # The design management context object needs to implement #issue
      DesignManagementObject = Struct.new(:issue)

      prepended do
        field :design_management, ::Types::DesignManagementType,
              null: false,
              description: 'Fields related to design management'

        field :instance_security_dashboard, ::Types::InstanceSecurityDashboardType,
              null: true,
              resolve: -> (_obj, _args, context) { InstanceSecurityDashboard.new(context[:current_user]) },
              description: 'Find an instance security dashboard',
              feature_flag: :instance_security_dashboard

        def design_management
          DesignManagementObject.new(nil)
        end
      end
    end
  end
end
