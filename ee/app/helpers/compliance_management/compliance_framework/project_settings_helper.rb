# frozen_string_literal: true

require_dependency 'compliance_management/compliance_framework'

module ComplianceManagement
  module ComplianceFramework
    module ProjectSettingsHelper
      def compliance_framework_options
        ::ComplianceManagement::Framework.all.map { |framework| [framework.display_name, framework.id] }
      end

      def compliance_framework_checkboxes
        ::ComplianceManagement::ComplianceFramework::FRAMEWORKS.map do |k, v|
          [v, compliance_framework_title_values.fetch(k)]
        end
      end

      def compliance_framework_tooltip(framework)
        s_("ComplianceFramework|This project is regulated by %{framework}." % { framework: framework.display_name })
      end

    end
  end
end
