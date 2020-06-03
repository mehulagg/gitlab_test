# frozen_string_literal: true

module EE
  module API
    module Entities
      Gate = Struct.new(:key, :name, :value)

      class FlipperFeature < Grape::Entity
        expose :name, as: :key
        expose :state do |flag|
          flag.enabled? ? 'on' : 'off'
        end
        expose :gates do |flag|
          flag.strategies.map do |strategy|
            gate = convert_strategy_to_gate(flag, strategy)
            FlipperGate.represent(gate) if gate
          end
        end

        def convert_strategy_to_gates(flag, strategy)
          if strategy.name == Operations::FeatureFlags::Strategy::STRATEGY_DEFAULT
            key = 'boolean'
            name = 'boolean'
            value = flag.enabled? ? 'true' : 'false'

            Gate.new(key, name, value)
          elsif strategy.name == Operations::FeatureFlags::Strategy::STRATEGY_USERWITHID
            key = 'actors'
            name = 'actor'
            value = strategy.parameters['userIds'] # TODO: Split the value by `,` and create multiple gates

            Gate.new(key, name, value)
          elsif strategy.name == Operations::FeatureFlags::Strategy::STRATEGY_GRADUALROLLOUTUSERID
            key = 'percentage_of_actors'
            name = 'percentage_of_actors'
            value = strategy.parameters['percentage']

            Gate.new(key, name, value)
          end
        end
      end
    end
  end
end
