# frozen_string_literal: true

module Gitlab
  module QuickActions
    module DslNew
      extend ActiveSupport::Concern

      # Mutations to inputs are reflected in the content of the union
      # This allows helpers to be defined after the commands and still be
      # reflected in their set of helpers
      class Union
        include Enumerable

        def initialize(xs, ys)
          @xs = xs
          @ys = ys
        end

        def each(&block)
          @xs.each(&block)
          @ys.each(&block)
        end
      end

      module BuildsHelper
        def build_helper(mod = nil, &block)
          raise ArgumentError, 'Both module and block provided' if mod && block_given?
          raise ArgumentError, 'mod or block must be provided' unless mod || block_given?
          raise ArgumentError, 'mod must be a Module' if mod && !mod.is_a(Module)

          block_given? ? Module.new(&block) : mod
        end
      end

      included do
        cattr_accessor :command_definitions, instance_accessor: false do
          []
        end

        cattr_accessor :command_definitions_by_name, instance_accessor: false do
          {}
        end
      end

      # Methods of this class are available during `command` blocks, can can be
      # used to define new commands.
      class Builder
        include BuildsHelper

        DuplicateAttribute = Class.new(StandardError)
        NoActionError = Class.new(StandardError)

        def initialize(helper_modules, types)
          @helper_modules = helper_modules
          @my_helpers = []
          @types = types if types
        end

        # [required] Defines the main action
        #
        # example:
        #
        #   command :my_command do
        #     action do |arg|
        #       update(my_arg: arg) # See: ExecutionContext
        #     end
        #   end
        def action(&block)
          set_attribute(:@action, block)
        end

        # Mark this as a dummy command. Dummy commands do not have action blocks
        def noop
          set_attribute(:@action, :dummy)
        end

        # Allows to give a description to the current quick action.
        # This description is shown in the autocomplete menu.
        #
        # See: QuickActions::ExecutionContext
        #
        # Example:
        #
        #   command :with_static_desc do
        #     desc 'Always the same'
        #     action do |arguments|
        #       # Awesome code block
        #     end
        #   end
        #
        #   command :with_dynamic_desc do
        #     desc do
        #       "This is a dynamic description for #{quick_action_target.to_ability_name}"
        #     end
        #     action do |arguments|
        #       # Awesome code block
        #     end
        #   end
        def desc(text = '', &block)
          set_attribute(:@description, block_given? ? block : text)
        end

        # Allows to give a description to the current quick action.
        # This will be shown in the explanation in parentheses.
        #
        # See: QuickActions::ExecutionContext
        #
        # Example:
        #
        #   command :with_static_warning do
        #     warning 'Always the same'
        #     action do |arguments|
        #       # Awesome code block
        #     end
        #   end
        #
        #   command :with_dynamic_warning do
        #     warning do
        #       "This is a dynamic warning for #{quick_action_target.to_ability_name}"
        #     end
        #     action do |arguments|
        #       # Awesome code block
        #     end
        #   end
        def warning(text = '', &block)
          set_attribute(:@warning, block_given? ? block : text)
        end

        # Sets the icon for the current quick action.
        #
        # Example:
        #
        #   command :with_pretty_icon do
        #     icon 'my-icon'
        #     action do |arguments|
        #       # Awesome code block
        #     end
        #   end
        def icon(string = '')
          set_attribute(:@icon, string)
        end

        # Allows to define params for the current quick action.
        # These params are shown in the autocomplete menu.
        #
        # Example:
        #
        #   command :awesome_command do
        #     params "~label ~label2"
        #     action |arguments|
        #       # Awesome code block
        #     end
        #   end
        def params(*params, &block)
          set_attribute(:@params, block_given? ? block : params)
        end

        # Allows to give an explanation of what the command will do when
        # executed. This explanation is shown when rendering the Markdown
        # preview.
        #
        # Example:
        #
        #   command :command_key do
        #     explanation do |arguments|
        #       "Adds label(s) #{arguments.join(' ')}"
        #     end
        #     action |arguments|
        #       # Awesome code block
        #     end
        #   end
        def explanation(text = '', &block)
          set_attribute(:@explanation, block_given? ? block : text)
        end

        # Allows to provide a message about quick action execution result. This
        # can be used to return a message on success. For failure, use the
        # `warn` method on the `ExecutionContext`.
        # This message is shown after quick action execution and after saving the note.
        #
        # Example:
        #
        #   command :command_key do
        #     execution_message do |arguments|
        #       "Added label(s) #{arguments.join(' ')}"
        #     end
        #     action |arguments|
        #       # Awesome code block
        #     end
        #   end
        #
        # Note: The execution_message won't be executed unless the condition block returns true.
        #       execution_message block is executed always after the command block has run,
        #       for this reason if the condition block doesn't return true after the command block has
        #       run you need to set the @execution_message variable inside the command block instead as
        #       shown in the following example.
        #
        # Example using `ExecutionContext#info` and `ExecutionContext#warn`:
        #
        #   command :command_key do
        #     execution_message do |arguments|
        #       if ok(arguments)
        #         info 'Something good'
        #       else
        #         warn 'Something bad'
        #       end
        #     end
        #     action |arguments|
        #       # Awesome code block
        #     end
        #   end
        #
        def execution_message(text = '', &block)
          set_attribute(:@execution_message, block_given? ? block : text)
        end

        # Allows to define type(s) that must be met in order for the command
        # to be returned by `.command_names` & `.command_definitions`.
        #
        # It is being evaluated before the conditions block is being evaluated
        #
        # To meet the types condition, the
        # `ExecutionContext#quick_action_target` must respond `true` to
        # `#is_a?(type)` for at least one of the provided types.
        #
        # If no types are passed then any type is allowed as the check is simply skipped.
        #
        # Example:
        #
        #   command :command_key do
        #     types Commit, Issue, MergeRequest
        #     action do |arguments|
        #       # Awesome code block
        #     end
        #   end
        def types(*types_list)
          set_attribute(:@types, types_list)
        end

        # Allows to define conditions that must be met in order for the command
        # to be returned by `.command_names` & `.command_definitions`.
        # It accepts a block that will be evaluated with the context
        # of an instance of [QuickActions::ExecutionContext]
        #
        # Example:
        #
        #   command :do_public_thing do
        #     condition do
        #       project.public?
        #     end
        #     action do
        #       # Awesome code block
        #     end
        #   end
        def condition(&block)
          set_attribute(:@condition_block, block)
        end

        # Allows to perform initial parsing of parameters. The result is passed
        # both to `command` and `explanation` blocks, instead of the raw
        # parameters.
        #
        # See: QuickActions::ExecutionContext
        #
        # Example:
        #
        #   command :command_key do
        #     parse_params do |raw|
        #       raw.strip
        #     end
        #     action |parsed|
        #       # Awesome code block
        #     end
        #   end
        def parse_params(&block)
          set_attribute(:@parse_params_block, block)
        end

        # Convenience short-cut for:
        #
        #   parse_params do |param|
        #     param.strip
        #   end
        def strips_param
          set_attribute(:@parse_params_block, proc { |string| string.strip })
        end

        # Add helpers that are only visible to this command
        def helpers(mod = nil, &block)
          @my_helpers << build_helper(mod, &block)
        end

        def to_h
          raise NoActionError, 'No action block' unless @action

          {
            description: @description,
            warning: @warning,
            icon: @icon,
            explanation: @explanation,
            execution_message: @execution_message,
            params: @params,
            condition_block: @condition_block,
            parse_params_block: @parse_params_block,
            action_block: @action == :dummy ? nil : @action,
            types: @types,
            helpers: all_helpers
          }
        end

        private

        def all_helpers
          Union.new(@helper_modules, @my_helpers)
        end

        def set_attribute(key, value)
          raise DuplicateAttribute, key.to_s[1..] if instance_variable_get(key)

          instance_variable_set(key, value)
        end
      end

      class_methods do
        include BuildsHelper

        # Registers a new command which is recognizable from body of email or
        # comment.
        # It accepts aliases and takes a block.
        #
        # The block is used to define the command, and is called in the context
        # of a Gitlab::QuickActions::Dsl::Builder instance. The `action` must be
        # defined, and `desc`, `types`, `condition` are recommended.
        #
        # Example:
        #
        #   command :my_command, :alias_for_my_command do
        #     desc 'Does great stuff'
        #     parse_params do |raw|
        #       ParamParser.parse(raw)
        #     end
        #     condition do |param|
        #       project.public? && acceptable?(param)
        #     end
        #     action |param|
        #       # Either set a key in the updates hash (recommended)
        #       update(my_command: param)
        #       # Or modify the target directly (if the update is not supported)
        #       quick_action_target.update(thing: param)
        #
        #       info 'my_command executed successfully'
        #     end
        #   end
        def command(*names, &block)
          build(::Gitlab::QuickActions::CommandDefinition, names, block)
        end

        # Registers a new substitution which is recognizable from body of email or
        # comment.
        # It accepts aliases and takes a block with the formatted content.
        #
        # Example:
        #
        #   command :my_substitution, :alias_for_my_substitution do
        #     action |text|
        #       "#{text} MY AWESOME SUBSTITUTION"
        #     end
        #   end
        def substitution(*names, &block)
          build(::Gitlab::QuickActions::SubstitutionDefinition, names, block)
        end

        # Types that apply to all commands defined in this module
        #
        # Example:
        #
        #   types Issue
        #
        #   command :one do
        #     action do
        #       # something
        #     end
        #   end
        #
        #   command :two do
        #     action do
        #       # something else
        #     end
        #   end
        def types(*types_list)
          @types = types_list
        end

        def helpers(mod = nil, &block)
          modules = helper_modules
          modules << build_helper(mod, &block)
        end

        private

        def helper_modules
          @helper_modules ||= []
        end

        def module_types
          @types
        end

        def build(klass, names, define)
          builder = Builder.new(helper_modules, module_types)
          builder.instance_exec(&define)
          define_command(klass, names, builder.to_h)
        end

        def define_command(klass, command_names, attributes)
          name, *aliases = command_names

          definition = klass.new(name, attributes.merge({ aliases: aliases }))

          self.command_definitions << definition

          definition.all_names.each do |name|
            self.command_definitions_by_name[name] = definition
          end
        end
      end
    end
  end
end
