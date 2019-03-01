# frozen_string_literal: true

module Gitlab
  module WebIde
    class Config
      module Entry
        module Validators
          class PortNamePresentAndUniqueValidator < ActiveModel::EachValidator
            def validate_each(record, attribute, value)
              return unless value.is_a?(Array)

              ports_size = value.count
              return if ports_size <= 1

              named_ports = value.select { |e| e.is_a?(Hash) }.map { |e| e[:name] }.compact.map(&:downcase)

              if ports_size != named_ports.size
                record.errors.add(attribute, 'when there is more than one port, a unique name should be added')
              end

              if ports_size != named_ports.uniq.size
                record.errors.add(attribute, 'each port name must be different')
              end
            end
          end

          class PortUniqueValidator < ActiveModel::EachValidator
            def initialize(options)
              super
              @external = options.fetch(:external, true)
            end

            def validate_each(record, attribute, value)
              value = data_pool(record, value)
              return unless value.is_a?(Array)

              ports_size = value.count
              return if ports_size <= 1

              if transform_ports(value).size != ports_size
                record.errors.add(attribute, error_message)
              end
            end

            private

            def data_pool(record, current_data)
              data = options.fetch(:data, current_data)
              data.is_a?(Proc) ? data.yield(record) : data
            end

            def transform_ports(raw_ports)
              raw_ports.map do |port|
                case port
                when Integer
                  port
                when Array
                  port[port_in_array]
                when Hash
                  port_in_hash(port)
                end
              end.uniq
            end

            def port_in_array
              @external ? 0 : 1
            end

            def port_in_hash(hash)
              if @external
                hash[:external_port]
              else
                hash.fetch(:internal_port, hash[:external_port])
              end
            end

            def error_message
              if @external
                'each external port can only be referenced once in the block'
              else
                'the same internal port is referenced more than once'
              end
            end
          end

          class ExternalPortUniqueValidator < PortUniqueValidator
            def initialize(options)
              super(options.merge(external: true))
            end
          end

          class InternalPortUniqueValidator < PortUniqueValidator
            def initialize(options)
              super(options.merge(external: false))
            end
          end
        end
      end
    end
  end
end
