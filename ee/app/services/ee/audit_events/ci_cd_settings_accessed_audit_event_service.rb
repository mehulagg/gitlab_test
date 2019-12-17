# frozen_string_literal: true

module EE
  module AuditEvents
    class CiCdSettingsAccessedAuditEventService < CustomAuditEventService
      def initialize(author, entity, ip_address)
        super(author, entity, ip_address, 'Accessed CI/CD settings')
      end
    end
  end
end
