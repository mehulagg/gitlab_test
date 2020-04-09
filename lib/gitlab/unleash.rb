# frozen_string_literal: true

module Gitlab
  module Unleash
    def self.enabled?(feature, context: nil, default_enabled: false)
      return default_enabled unless unleash_ready?

      client.enabled? feature.to_s, context, default_enabled
    end

    private_class_method def self.unleash_ready?
      Feature.enabled?(:gitlab_unleash_client) && !client.nil?
    end

    private_class_method def self.client
      Rails.configuration.unleash if Rails.configuration.respond_to?(:unleash)
    end
  end
end
