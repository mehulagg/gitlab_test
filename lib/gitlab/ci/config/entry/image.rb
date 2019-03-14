# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a Docker image.
        #
        class Image < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Validatable

          ALLOWED_KEYS = %i[name entrypoint].freeze

          validations do
            include ::Gitlab::Ci::Config::Entry::Validations::Image

            validates :config, allowed_keys: ALLOWED_KEYS
          end

          def name
            value[:name]
          end

          def entrypoint
            value[:entrypoint]
          end

          def value
            return { name: @config } if string?
            return @config if hash?

            {}
          end
        end
      end
    end
  end
end
