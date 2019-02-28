# frozen_string_literal: true

module Gitlab
  module WebIde
    class Config
      module Entry
        ##
        # Entry that represents a configuration of Docker service.
        #
        class Service < Image
          include ::Gitlab::Config::Entry::Validatable
          include ::Gitlab::Config::Entry::Attributable

          ALLOWED_KEYS = [:command, :alias, *ALLOWED_KEYS].freeze

          validations do
            validates :config, hash_or_string: true
            validates :config, allowed_keys: ALLOWED_KEYS

            validates :name, type: String, presence: true
            validates :entrypoint, array_of_strings: true, allow_nil: true
            validates :command, array_of_strings: true, allow_nil: true
            validates :alias, type: String, allow_nil: true
          end

          attributes :alias, :command
        end
      end
    end
  end
end
