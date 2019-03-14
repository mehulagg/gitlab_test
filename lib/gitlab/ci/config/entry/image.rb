# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a Docker image.
        #
        class Image < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Validatable
          include ::Gitlab::Config::Entry::Attributable
          include ::Gitlab::Config::Entry::Configurable

          ALLOWED_KEYS = %i[name entrypoint ports].freeze

          validations do
            include ::Gitlab::Ci::Config::Entry::Validations::Image

            validates :config, allowed_keys: ALLOWED_KEYS
            validates :config, disallowed_keys: %i[ports], unless: :with_image_ports?
          end

          entry :ports, Entry::Ports,
            description: 'Ports used expose the service'

          attributes :ports

          def name
            value[:name]
          end

          def entrypoint
            value[:entrypoint]
          end

          def value
            return { name: @config } if string?
            return @config if hash?

            {}
          end

          def with_image_ports?
            opt(:with_image_ports)
          end

          def skip_config_hash_validation?
            false
          end
        end
      end
    end
  end
end
