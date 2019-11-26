# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a release configuration.
        #
        class Release < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Configurable
          include ::Gitlab::Config::Entry::Validatable

          ALLOWED_KEYS = %i[tag name description assets].freeze

          entry :assets, Entry::Assets, description: 'Release assets.'

          validations do
            validates :config, allowed_keys: ALLOWED_KEYS
            validates :description, type: String, presence: true
          end

          helpers :assets

          def value
            @config[:assets] = assets_value if @config.key?(:assets)
            @config
          end
        end
      end
    end
  end
end
