# frozen_string_literal: true

module Types
  module ComplianceManagement
    class ProjectSettingEnum < Types::BaseEnum
      description 'Names of compliance frameworks that can be assigned to a Project'

      ::ComplianceManagement::Framework.all.each do |framework|
        value(framework.name)
      end
    end
  end
end
