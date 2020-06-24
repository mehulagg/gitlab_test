# frozen_string_literal: true

module Gitlab
  module PersonalAccessTokens
    class RotationVerifier
      include ReactiveCaching
      DAYS_WITHIN = Expirable::DAYS_TO_EXPIRE.days

      self.reactive_cache_key = ->(service) { [service.class.model_name.singular, service.id] }
      self.reactive_cache_worker_finder = ->(id) { from_cache(id) }

      attr_reader :user

      def initialize(user)
        @user = user
      end

      def id
        user&.id
      end

      # If a new token has been created after we started notifying the user about the most recently EXPIRED token,
      # rotation is NOT needed.
      # For example: If the most recent token expired on 14th of June, and user created a token anytime on or after
      # 7th of June (first notification date), no rotation is required.
      def expired?
        with_reactive_cache do |data|
          data
        end
      end

      def calculate_reactive_cache
        most_recent_expires_at = user.personal_access_tokens.without_impersonation.not_revoked.expired.maximum(:expires_at)

        return false if most_recent_expires_at.nil?

        !user.personal_access_tokens.without_impersonation.created_on_or_after(most_recent_expires_at - DAYS_WITHIN).exists?
      end

      # If a new token has been created after we started notifying the user about the most recently EXPIRING token,
      # rotation is NOT needed.
      # User is notified about an expiring token before `days_within` (7 days) of expiry
      def expiring_soon?
        most_recent_expires_at = user.personal_access_tokens.without_impersonation.expires_in(DAYS_WITHIN.from_now).maximum(:expires_at)

        return false if most_recent_expires_at.nil?

        !user.personal_access_tokens.without_impersonation.created_on_or_after(most_recent_expires_at - DAYS_WITHIN).exists?
      end

      private

      def self.from_cache(user_id)
        user = User.find(user_id)

        new(user)
      end
    end
  end
end
