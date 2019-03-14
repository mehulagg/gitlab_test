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

          ALLOWED_KEYS = %i[name entrypoint command alias].freeze

          validations do
            include ::Gitlab::Ci::Config::Entry::Validations::Service

            validates :config, allowed_keys: ALLOWED_KEYS
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
