# frozen_string_literal: true

module Elastic
  module Latest
    class QueryFactory
      @stack = []

      def self.query_context(*args, &block)
        name = if current_query_context
                 Gitlab::Elastic::ExprName.build(*current_query_context, *args)
               else
                 Gitlab::Elastic::ExprName.build(*args)
               end

        return name unless block_given?

        begin
          @stack.push(name)
          yield name
        ensure
          @stack.pop
        end
      end

      def self.query_name(*args)
        return current_query_context.name(*args) if current_query_context

        Gitlab::Elastic::ExprName.build(*args).name
      end

      def self.current_query_context
        return if @stack.empty?

        @stack.last
      end
    end
  end
end
