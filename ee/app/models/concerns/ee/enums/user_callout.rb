# frozen_string_literal: true

module EE
  module Enums
    module UserCallout
      extend ActiveSupport::Concern

      class_methods do
        extend ::Gitlab::Utils::Override

        # If you are going to add new items to this hash, check that you're not going
        # to conflict with FOSS-only values: https://gitlab.com/gitlab-org/gitlab/blob/master/app/models/concerns/enums/user_callout.rb
        override :feature_names
        def feature_names
          super.merge(
            gold_trial: 4,
            geo_enable_hashed_storage: 5,
            geo_migrate_hashed_storage: 6,
            canary_deployment: 7,
            gold_trial_billings: 8,
            threat_monitoring_info: 11,
            account_recovery_regular_check: 12,
            active_user_count_threshold: 18,
            buy_pipeline_minutes_notification_dot: 19
          )
        end
      end
    end
  end
end
