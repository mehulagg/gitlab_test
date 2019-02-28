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
            validates :config, type: Array

            validate do
              next if ports_size <= 1

              # If we only have 1 port we don't need this checkings because it will use
              # the default port name
              unless name_exist?
                errors.add(:config, 'when there is more than one port, a unique name should be added')
              end

              unless unique_names?
                errors.add(:config, 'each port name must be different')
              end

              unless unique_external_ports?
                errors.add(:config, 'each external port can only be referenced once in the block')
              end

              unless unique_internal_ports?
                errors.add(:config, 'the same internal port is referenced more than once')
              end
            end

            # Checking if we have the same number of ports and names
            def name_exist?
              ports_size == port_names.size
            end

            # Each port must have a unique name. The names are case insensitive
            def unique_names?
              ports_size == port_names.uniq.size
            end

            def unique_external_ports?
              ports = config.map do |port|
                case port
                when Integer
                  port
                when Array
                  port[0]
                when Hash
                  port[:external_port]
                end
              end

              ports.uniq.size == ports_size
            end

            def unique_internal_ports?
              ports = config.map do |port|
                case port
                when Integer
                  port
                when Array
                  port[1]
                when Hash
                  port.fetch(:internal_port, port[:external_port])
                end
              end

              ports.uniq.size == ports_size
            end

            def ports_size
              @port_size ||= config.is_a?(Array) ? config.size : 0
            end

            def port_names
              @port_names ||= begin
                config.select { |e| e.is_a?(Hash) }.map { |e| e[:name] }.compact.map(&:downcase)
              end
            end
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
