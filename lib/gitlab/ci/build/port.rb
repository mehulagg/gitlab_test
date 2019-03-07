# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      class Port
        DEFAULT_PORT_NAME = 'default_port'.freeze
        DEFAULT_BUILD_NAME = 'build'.freeze

        attr_reader :number, :insecure, :name

        def initialize(port)
          @name = DEFAULT_PORT_NAME
          @insecure = false

          case port
          when Integer
            @number = port
          when Hash
            @number = port[:number]
            @insecure = port.fetch(:insecure, @insecure)
            @name = port.fetch(:name, @name)
          end
        end

        def valid?
          @number.present?
        end
      end
    end
  end
end
