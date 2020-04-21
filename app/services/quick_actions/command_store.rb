# frozen_string_literal: true

module QuickActions
  class CommandStore
    include Singleton

    CommandNameCollision = Class.new(ArgumentError)

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

      collisions = @command_definitions
        .flat_map(&:all_names)
        .group_by(&:itself).values
        .select { |grp| grp.size > 1 }
        .map(&:first)

      if collisions.any?
        raise CommandNameCollision, collisions.join(', ')
      end
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

        definition.to_h(context)
      end.compact
    end
  end
end

QuickActions::CommandStore.prepend_if_ee('EE::QuickActions::CommandStore')
