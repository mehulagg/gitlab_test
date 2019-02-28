# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Build
        class Port
          DEFAULT_PORT_NAME = 'default_port'.freeze

          attr_reader :external_port, :internal_port, :insecure, :name

          def initialize(port)
            @name = DEFAULT_PORT_NAME

            case port
            when Integer
              @external_port = @internal_port = port
            when Array
              @external_port, @internal_port = port
            when Hash
              @external_port = port[:external_port]
              @internal_port = port.fetch(:internal_port, @external_port)
              @insecure = port.fetch(:insecure, false)
              @name = port.fetch(:name, @name)
            end
          end

          def valid?
            @external_port.present? && @internal_port.present?
          end
        end
      end
    end
  end
end
