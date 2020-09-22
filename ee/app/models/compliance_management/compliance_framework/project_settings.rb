# frozen_string_literal: true

require_dependency 'compliance_management/compliance_framework'

module ComplianceManagement
  module ComplianceFramework
    class ProjectSettings < ApplicationRecord
      self.table_name = 'project_compliance_framework_settings'
      self.primary_key = :project_id

      belongs_to :project
      belongs_to :framework, class_name: 'ComplianceManagement::Framework', foreign_key: :framework

      validates :project, presence: true
      validates :framework, uniqueness: { scope: [:project_id] }
    end
  end
end
