# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a Docker image.
        #
        class Image < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Attributable
          include ::Gitlab::Config::Entry::Configurable

          ALLOWED_KEYS = %i[name entrypoint ports].freeze

          validations do
            # ::Gitlab::Config::Entry::Configurable adds a type validation
            # to the config because a hash is expected.
            # Nevertheless, we allow images to be a string or a hash
            # Therefore we have to remove that first validation
            reset_callbacks(:validate)

            validates :config, hash_or_string: true
            validates :config, allowed_keys: ALLOWED_KEYS

            validates :name, type: String, presence: true
            validates :entrypoint, array_of_strings: true, allow_nil: true
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
        end
      end
    end
  end
end
