# frozen_string_literal: true

module Gitlab
  module QuickActions
    # Wrapper around the common exeution context providing cached argument
    # parsing.
    class CommandContext < SimpleDelegator
      include Gitlab::Utils::StrongMemoize

      def initialize(common_context, definition, arg = nil)
        super(common_context)
        @definition = definition
        @arg = arg
      end

      def argument
        strong_memoize(:argument) do
          next @arg unless @arg.present? && @definition.parse_params_block

          instance_exec(@arg, &@definition.parse_params_block)
        end
      end

      def method_missing(sym, *args)
        if @definition.argument_alias == sym && args.empty?
          argument
        else
          super
        end
      end
    end
  end
end
