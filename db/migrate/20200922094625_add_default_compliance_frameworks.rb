# frozen_string_literal: true

class AddDefaultComplianceFrameworks < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false
  DEFAULT_FRAMEWORKS = [
      {
          name: 'GDPR',
          description: 'General Data Protection Regulation',
          id: 1,
          color: '#1aaa55'
      },
      {
          name: 'HIPAA',
          description: 'Health Insurance Portability and Accountability Act',
          id: 2,
          color: '#1f75cb'
      },
      {
          name: 'PCI-DSS',
          description: 'Payment Card Industry-Data Security Standard',
          id: 3,
          color: '#6666c4'
      },
      {
          name: 'SOC 2',
          description: 'Service Organization Control 2',
          id: 4,
          color: '#dd2b0e'
      },
      {
          name: 'SOX',
          description: 'Sarbanes-Oxley',
          id: 5,
          color: '#fc9403'
      }
  ]

  def up
    DEFAULT_FRAMEWORKS.each do |framework|
      ComplianceManagement::Framework.create!(framework)
    end
    add_foreign_key :project_compliance_framework_settings,
                    :compliance_management_frameworks,
                    on_delete: :cascade, validate: false, column: :framework
  end

  def down
    ComplianceManagement::ComplianceFramework::FRAMEWORKS.each do |_, v|
      ComplianceManagement::Framework.delete(v)
    end

    remove_foreign_key_if_exists :project_compliance_framework_settings, column: :framework
  end
end
