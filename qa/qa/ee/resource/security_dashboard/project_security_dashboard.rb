# frozen_string_literal: true

module QA
  module EE
    module Resource
      module SecurityDashboard
        class ProjectSecurityDashboard < Base
          attribute :project

          def api_get_path
            "/projects/#{project.id}/-/security/dashboard"
          end
        end
      end
    end
  end
end
