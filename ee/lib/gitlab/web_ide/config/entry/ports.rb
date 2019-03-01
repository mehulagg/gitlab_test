# frozen_string_literal: true

module Gitlab
  module WebIde
    class Config
      module Entry
        ##
        # Entry that represents a configuration of Docker services.
        #
        class Ports < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Validatable

          validations do
            include ::Gitlab::WebIde::Config::Entry::Validators

            validates :config, type: Array
            validates :config, port_name_present_and_unique: true
            validates :config, external_port_unique: true
          end

          def compose!(deps = nil)
            super do
              @entries = []
              @config.each do |config|
                @entries << ::Gitlab::Config::Entry::Factory.new(Entry::Port)
                  .value(config || {})
                  .create!
              end

              @entries.each do |entry|
                entry.compose!(deps)
              end
            end
          end

          def value
            @entries.map(&:value)
          end

          def descendants
            @entries
          end
        end
      end
    end
  end
end
