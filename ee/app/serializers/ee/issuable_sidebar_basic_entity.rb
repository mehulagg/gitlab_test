# frozen_string_literal: true

module EE
  module IssuableSidebarBasicEntity
    extend ActiveSupport::Concern

    prepended do
      expose :scoped_labels_available do |issuable|
        issuable.project&.feature_available?(:scoped_labels)
      end

      expose :supports_weight?, as: :supports_weight

      expose :request_cve_enabled do |issuable|
        security_setting = ProjectSecuritySetting.safe_find_or_create_for(issuable.project)
        issuable_type = issuable.class.to_s.underscore

        issuable_type == 'issue' \
          && ::Gitlab.dev_env_or_com? \
          && (issuable.respond_to?(:confidential) && issuable.confidential ) \
          && security_setting.cve_id_request_enabled == true \
          && issuable.project.visibility_level == ::Gitlab::VisibilityLevel::PUBLIC \
          && can?(current_user, :admin_project, issuable.project)
      end
    end
  end
end
