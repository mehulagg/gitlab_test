# frozen_string_literal: true

module QuickActions
  class InterpretService < BaseService
    attr_reader :quick_action_target, :content, :current_command

    def initialize(project, target, user = nil, content = nil, params = {})
      super(project, user, params)
      @quick_action_target = target
      @content = content
      @execution_message = {}
      @execution_warning = {}
      @commands_executed = []
    end

    def command_store
      @command_store ||= ::QuickActions::CommandStore.instance
    end

    # Counts how many commands have been executed.
    # Used to display relevant feedback on UI when a note
    # with only commands has been processed.
    def commands_executed_count
      @commands_executed.size
    end

    def self.null_explanation(content)
      ExplainResponse.new(content, [])
    end

    # Takes an quick_action_target and returns an array of all the available commands
    # represented with .to_h
    def available_commands
      command_store.available_commands(create_context)
    end

    # Takes a text and interprets the commands that are extracted from it.
    # Returns an ExecutionResponse
    def execute(only: nil)
      return null_response unless current_user.can?(:use_quick_actions)

      trimmed_content, commands = extractor.extract_commands(content, only: only)
      context = create_context
      run_definitions(commands, context)

      ExecutionResponse.new(trimmed_content, current_user,
                            updates: context.updates,
                            messages: execution_messages_for(commands, context),
                            warnings: execution_warnings_for(commands, context),
                            count: commands_executed_count,
                            commands: commands)
    end

    ExplainResponse = Struct.new(:content, :messages)

    # Takes a text and interprets the commands that are extracted from it.
    # Returns the content without commands, and array of changes explained.
    def explain
      return ExplainResponse.new(content, []) unless current_user.can?(:use_quick_actions)

      trimmed_content, commands = extractor.extract_commands(content)
      ExplainResponse.new(trimmed_content, explain_commands(commands, create_context))
    end

    def null_response
      ExecutionResponse.new(content, current_user)
    end

    private

    def create_context
      ::QuickActions::ExecutionContext.new(self,
                                           @execution_message, @execution_warning,
                                           @commands_executed)
    end

    def extractor
      @extractor ||= command_store.extractor
    end

    def explain_commands(commands, context)
      map_commands(commands, :explain, context)
    end

    def execution_messages_for(commands, context)
      map_commands(commands, :execute_message, context).uniq.join(' ')
    end

    def execution_warnings_for(commands, context)
      map_commands(commands, :execution_warning, context).join(' ')
    end

    def map_commands(commands, method, context)
      commands.map do |name, arg|
        definition = command_store[name]
        next unless definition

        case method
        when :explain
          with_name(name, arg) { definition.explain(context, arg) }
        when :execute_message
          @execution_message[name.to_sym] || definition.execute_message(context, arg)
        when :execution_warning
          # run execution message block to capture warnings
          with_name(name, arg) { definition.execute_message(context, arg) }
          @execution_warning[name.to_sym]
        end
      end.compact
    end

    def run_definitions(commands, context)
      commands.each do |name, arg|
        definition = command_store[name]
        next unless definition

        with_name(name, arg) { definition.execute(context, arg) }
      end
    end

    def with_name(name, arg)
      @current_command = name.to_sym
      ret = yield
      @current_command = nil
      ret
    end
  end
end
