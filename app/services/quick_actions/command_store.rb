# frozen_string_literal: true

module QuickActions
  class CommandStore
    attr_reader :command_definitions

    def initialize(modules)
      @command_definitions = modules.flat_map(&:command_definitions).freeze
      @command_definitions_by_name = modules.reduce({}) do |defs, mod|
        defs.merge!(mod.command_definitions_by_name)
      end.freeze
      freeze
    end

    def [](name)
      @command_definitions_by_name[name.to_sym]
    end

    def available_commands(context)
      command_definitions.map do |definition|
        next unless definition.available?(context)

        definition.to_h(self)
      end.compact
    end
  end
end
