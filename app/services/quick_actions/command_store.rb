# frozen_string_literal: true

module QuickActions
  class CommandStore
    include Singleton

    attr_reader :command_definitions

    COMMAND_MODULES = [
      Gitlab::QuickActions::IssueActions,
      Gitlab::QuickActions::IssuableActions,
      Gitlab::QuickActions::IssueAndMergeRequestActions,
      Gitlab::QuickActions::MergeRequestActions,
      Gitlab::QuickActions::CommitActions,
      Gitlab::QuickActions::CommonActions
    ].freeze

    def self.command_modules
      COMMAND_MODULES
    end

    def initialize
      modules = self.class.command_modules
      @command_definitions = modules.flat_map(&:command_definitions).freeze
      @command_definitions_by_name = modules.reduce({}) do |defs, mod|
        defs.merge!(mod.command_definitions_by_name)
      end.freeze
      freeze
    end

    def extractor
      Gitlab::QuickActions::Extractor.new(command_definitions)
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

QuickActions::CommandStore.prepend_if_ee('EE::QuickActions::CommandStore')
