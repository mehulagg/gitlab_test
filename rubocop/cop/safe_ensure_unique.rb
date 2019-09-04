# frozen_string_literal: true

module RuboCop
  module Cop
    # This cop checks for rescuing `ActiveRecord::RecordNotUnique`.
    #
    # @example
    #
    #   # bad
    #   begin
    #     foo.save
    #   rescue ActiveRecord::RecordNotFound
    #     retry
    #   end
    #
    #   # good
    #   Foo.safe_ensure_unique(retries: 1) do
    #     foo.save
    #   end
    #
    class SafeEnsureUnique < RuboCop::Cop::Cop
      MSG = 'Use safe_ensure_unique instead. For more details check https://gitlab.com/gitlab-org/gitlab-ce/issues/60342.'

      def_node_matcher :rescue_active_record_not_unique?, <<~PATTERN
        (resbody $(array (const (const nil? :ActiveRecord) :RecordNotUnique)) _ _)
      PATTERN

      def on_resbody(node)
        rescue_active_record_not_unique?(node) do |error|
          add_offense(
            node,
            location: node.loc.keyword.join(error.loc.expression)
          )
        end
      end
    end
  end
end
