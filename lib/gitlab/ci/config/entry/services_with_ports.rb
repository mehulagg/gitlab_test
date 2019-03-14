# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a configuration of Docker services.
        #
        class ServicesWithPorts < Entry::Services
          include ::Gitlab::Config::Entry::Validatable

          validations do
            validates :config, type: Array
          end

          protected

          def service_klass
            Entry::ServiceWithPorts
          end
        end
      end
    end
  end
end
