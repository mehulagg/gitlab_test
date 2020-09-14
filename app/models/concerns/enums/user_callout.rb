# frozen_string_literal: true

module Enums
  module UserCallout
    # Returns the `Hash` to use for the `feature_name` enum in the `UserCallout`
    # model.
    #
    # This method is separate from the `UserCallout` model so that it can be
    # extended by EE.
    #
    # If you are going to add new items to this hash, check that you're not going
    # to conflict with EE-only values: https://gitlab.com/gitlab-org/gitlab/blob/master/ee/app/models/concerns/ee/enums/user_callout.rb
    def self.feature_names
      {
        gke_cluster_integration: 1,
        gcp_signup_offer: 2,
        cluster_security_warning: 3,
        suggest_popover_dismissed: 9,
        tabs_position_highlight: 10,
        webhooks_moved: 13,
        service_templates_deprecated: 14,
        admin_integrations_moved: 15,
        web_ide_alert_dismissed: 16,
        personal_access_token_expiry: 21, # EE-only
        suggest_pipeline: 22,
        customize_homepage: 23,
        feature_flags_new_version: 24
      }
    end
  end
end

Enums::UserCallout.prepend_if_ee('EE::Enums::UserCallout')
