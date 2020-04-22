# frozen_string_literal: true

module Gitlab
  module QuickActions
    class CommandDefinition
      attr_accessor :name, :aliases, :description, :explanation, :execution_message,
        :params, :condition_block, :parse_params_block, :action_block, :warning, :icon, :types, :argument_alias

      def initialize(name, attributes = {})
        @name = name

        @aliases = attributes[:aliases] || []
        @description = attributes[:description] || ''
        @warning = attributes[:warning] || ''
        @icon = attributes[:icon] || ''
        @explanation = attributes[:explanation] || ''
        @execution_message = attributes[:execution_message] || ''
        @params = attributes[:params] || []
        @condition_block = attributes[:condition_block]
        @parse_params_block = attributes[:parse_params_block]
        @argument_alias = attributes[:argument_alias]
        @action_block = attributes[:action_block]
        @types = attributes[:types] || []
        @helpers = attributes[:helpers] || []
      end

      def all_names
        [name, *aliases]
      end

      def noop?
        action_block.nil?
      end

      def available?(context)
        return false unless valid_type?(context)
        return true unless condition_block

        helper_proxy.new(context, self).instance_exec(&condition_block)
      end

      def explain(context, arg)
        return unless available?(context)

        message = if explanation.respond_to?(:call)
                    execute_block(explanation, context, arg)
                  else
                    explanation
                  end

        warning_text = if warning.respond_to?(:call)
                         execute_block(warning, context, arg)
                       else
                         warning
                       end

        warning.empty? ? message : "#{message} (#{warning_text})"
      end

      def execute(context, arg)
        return unless executable?(context)

        context.record_command_execution

        execute_block(action_block, context, arg)
      end

      def execute_message(context, arg)
        return unless executable?(context)

        if execution_message.respond_to?(:call)
          execute_block(execution_message, context, arg)
        else
          execution_message
        end
      end

      def to_h(context)
        ctx = helper_proxy.new(context, self)
        desc = description
        if desc.respond_to?(:call)
          desc = ctx.instance_exec(&desc) rescue ''
        end

        warn = warning
        if warn.respond_to?(:call)
          warn = ctx.instance_exec(&warn) rescue ''
        end

        prms = params
        if prms.respond_to?(:call)
          prms = Array(ctx.instance_exec(&prms)) rescue params
        end

        {
          name: name,
          aliases: aliases,
          description: desc,
          warning: warn,
          icon: icon,
          params: prms
        }
      end

      private

      def executable?(context)
        !noop? && available?(context)
      end

      def execute_block(block, context, arg)
        ctx = helper_proxy.new(context, self, arg)

        if arg.present? && block.parameters.present?
          ctx.instance_exec(ctx.argument, &block)
        elsif block.arity == 0
          ctx.instance_exec(&block)
        end
      end

      def parse_params(arg, context)
        return arg unless parse_params_block

        context.instance_exec(arg, &parse_params_block)
      end

      def valid_type?(context)
        types.blank? || types.any? { |type| context.quick_action_target.is_a?(type) }
      end

      def helper_proxy
        @helper_proxy ||= build_proxy
      end

      def build_proxy
        mods = @helpers

        if mods.empty?
          CommandContext
        else
          Class.new(CommandContext) do
            mods.each { |m| include(m) }
          end
        end
      end
    end
  end
end
