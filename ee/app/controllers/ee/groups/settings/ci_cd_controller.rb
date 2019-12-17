# frozen_string_literal: true
module EE
  module Groups
    module Settings
      module CiCdController
        extend ActiveSupport::Concern

        prepended do
          before_action :log_access_ci_cd_settings, only: :show
        end

        def log_access_ci_cd_settings
          AuditEvents::CiCdSettingsAccessedAuditEventService.new(
            current_user,
            group,
            request.remote_ip
          ).for_group.security_event
        end
      end
    end
  end
end
