# frozen_string_literal: true

module EE
  module Projects
    module GroupLinksController
      extend ::Gitlab::Utils::Override
      extend ActiveSupport::Concern

      prepended do
        before_action :authorize_group_share!, only: [:create]
      end

      protected

      def authorize_group_share!
        access_denied! unless project.allowed_to_share_with_group?
      end

      private

      override :update_gitlab_subscription
      def update_gitlab_subscription
        ::Gitlab::Subscription::MaxSeatsUpdater.update(project)
      end
    end
  end
end
