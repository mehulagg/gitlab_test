# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a configuration of Docker service.
        #
        class Service < Image
          include ::Gitlab::Config::Entry::Validatable

          ALLOWED_KEYS_WITH_PORTS = %i[name entrypoint command alias ports].freeze

          validations do
            include ::Gitlab::Ci::Config::Entry::Validations::Service

            validates :config, allowed_keys: ALLOWED_KEYS
            validates :alias, type: String, presence: true, unless: ->(record) { record.ports.blank? }
          end

          def alias
            value[:alias]
          end

          def command
            value[:command]
          end
        end
      end
    end
  end
end
