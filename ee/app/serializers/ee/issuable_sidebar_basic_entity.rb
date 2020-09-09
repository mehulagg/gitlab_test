# frozen_string_literal: true

module EE
  module IssuableSidebarBasicEntity
    extend ActiveSupport::Concern

    prepended do
      expose :scoped_labels_available do |issuable|
        issuable.project&.feature_available?(:scoped_labels)
      end

      expose :cve_id_request_is_enabled do |issuable|
        security_setting ||= ProjectSecuritySetting.safe_find_or_create_for(issuable.project)
        security_setting.cve_id_request_enabled == true
      end
    end
  end
end
