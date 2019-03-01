# frozen_string_literal: true

module Gitlab
  module WebIde
    class Config
      module Entry
        ##
        # Entry that represents a Docker image.
        #
        class Image < ::Gitlab::Ci::Config::Entry::Image
          include ::Gitlab::Config::Entry::Configurable
          include ::Gitlab::Config::Entry::Attributable

          ALLOWED_KEYS = [:ports, *ALLOWED_KEYS].freeze

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
        end
      end
    end
  end
end
