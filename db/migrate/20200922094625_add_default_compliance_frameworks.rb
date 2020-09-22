# frozen_string_literal: true

class AddDefaultComplianceFrameworks < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  def up
    ComplianceManagement::ComplianceFramework::FRAMEWORKS.each do |k, v|
      ComplianceManagement::Framework.create!({ id: v, name: k, color: '#111111' })
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
