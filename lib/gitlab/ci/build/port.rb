# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      class Port
        DEFAULT_PORT_NAME = 'default_port'.freeze

        attr_reader :externalport, :internalport, :ssl, :name

        def initialize(port)
          @ssl = true
          @name = DEFAULT_PORT_NAME

          case port
          when Integer
            @externalport = @internalport = port
          when Array
            @externalport, @internalport = port
          when Hash
            @externalport = port[:externalport]
            @internalport = port.fetch(:internalport, @externalport)
            @ssl = port.fetch(:ssl, @ssl)
            @name = port.fetch(:name, @name)
          end
        end

        def valid?
          @externalport.present? && @internalport.present?
        end
      end
    end
  end
end
