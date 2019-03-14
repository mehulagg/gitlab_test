# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a configuration of an Image Port.
        #
        class Port < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Validatable

          ALLOWED_KEYS = %i[number insecure name].freeze

          validations do
            validates :config, hash_or_integer: true
            validates :config, allowed_keys: ALLOWED_KEYS

            validates :number, type: Integer, presence: true
            validates :insecure, boolean: true, presence: false
            validates :name, type: String, presence: false, allow_nil: true
          end

          def number
            value[:number]
          end

          def insecure
            value.fetch(:insecure, false)
          end

          def name
            value[:name]
          end

          def value
            return { number: @config } if integer?
            return @config if hash?

            {}
          end
        end
      end
    end
  end
end
