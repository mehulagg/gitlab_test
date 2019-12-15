# frozen_string_literal: true
module EE
  module Groups
    module Settings
      module CiCdController
        extend ActiveSupport::Concern

        prepended do
          before_action :log_access_ci_cd_settings, only: :show
        end

        def log_audit_event(message:)
          AuditEvents::CustomAuditEventService.new(
            current_user,
            group,
            request.remote_ip,
            message
          ).for_group.security_event
        end

        def log_access_ci_cd_settings
          log_audit_event(message: 'Accessed CI/CD settings')
        end
      end
    end
  end
end
