# frozen_string_literal: true

module Gitlab
  module WebIde
    class Config
      module Entry
        ##
        # Entry that represents a configuration of an Image Port.
        #
        class Port < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Validatable

          ALLOWED_KEYS = %i[external_port internal_port insecure name].freeze

          validations do
            validates :config, hash_or_array_or_integer: true
            validates :config, allowed_keys: ALLOWED_KEYS

            validates :external_port, type: Integer, presence: true
            validates :internal_port, type: Integer, presence: true
            validates :insecure, boolean: true, presence: false
            validates :name, type: String, presence: false, allow_nil: true
          end

          def external_port
            value[:external_port]
          end

          def internal_port
            value[:internal_port]
          end

          def insecure
            value.fetch(:insecure, false)
          end

          def name
            value[:name]
          end

          def array_of_integers?(size: nil)
            @config.is_a?(Array) && (size.blank? || @config.size == size)
          end

          def value
            return { external_port: @config, internal_port: @config } if integer?
            return { external_port: @config.first, internal_port: @config.last } if array_of_integers?(size: 2)

            if hash?
              @config[:internal_port] ||= @config[:external_port]

              return @config
            end

            {}
          end
        end
      end
    end
  end
end
