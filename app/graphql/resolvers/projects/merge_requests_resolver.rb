# frozen_string_literal: true

module Resolvers
  module Projects
    class MergeRequestsResolver < BaseMergeRequestsResolver
      include MergeRequestUserArguments

      user_mr_argument :author
      user_mr_argument :assignee

      alias_method :project, :synchronized_object

      def self.single
        ::Resolvers::Projects::MergeRequestResolver
      end

      def no_results_possible?(args)
        project.nil? || some_argument_is_empty?(args)
      end

      def some_argument_is_empty?(args)
        args.values.any? { |v| v.is_a?(Array) && v.empty? }
      end
    end
  end
end
