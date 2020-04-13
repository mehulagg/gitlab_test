# frozen_string_literal: true

module QuickActions
  class CommandStore
    attr_reader :command_definitions, :command_definitions_by_name

    def initialize(modules)
      @command_definitions = modules.flat_map(&:command_definitions).freeze
      @command_definitions_by_name = modules.reduce({}) do |defs, mod|
        defs.merge!(mod.command_definitions_by_name)
      end.freeze
      freeze
    end

    def definition_by_name(name)
      command_definitions_by_name[name.to_sym]
    end
  end
end
