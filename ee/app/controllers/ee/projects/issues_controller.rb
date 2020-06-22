# frozen_string_literal: true

module EE
  module Projects
    module IssuesController
      extend ActiveSupport::Concern

      prepended do
        include DescriptionDiffActions

        before_action :whitelist_query_limiting_ee, only: [:update]

        before_action do
          push_frontend_feature_flag(:save_issuable_health_status, project.group, default_enabled: true)
        end
      end

      private

      def issue_params_attributes
        attrs = super
        attrs.unshift(:weight) if project.feature_available?(:issue_weights)
        attrs.unshift(:epic_id) if project.group&.feature_available?(:epics)

        attrs
      end

      def finder_options
        options = super

        options.reject! { |key| key == 'weight' } unless project.feature_available?(:issue_weights)

        options
      end

      def whitelist_query_limiting_ee
        ::Gitlab::QueryLimiting.whitelist('https://gitlab.com/gitlab-org/gitlab/issues/4794')
      end
    end
  end
end
