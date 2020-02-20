# frozen_string_literal: true

module EE
  module Members
    module BaseService
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      private

      override :update_gitlab_subscription
      def update_gitlab_subscription(membershipable)
        ::Gitlab::Subscription::MaxSeatsUpdater.update(membershipable)
      end
    end
  end
end
