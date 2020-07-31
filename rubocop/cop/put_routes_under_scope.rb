# frozen_string_literal: true

module RuboCop
  module Cop
    # Checks for a routes outside '/-/' scope.
    # For more information see: https://gitlab.com/gitlab-org/gitlab/issues/29572
    class PutRoutesUnderScope < RuboCop::Cop::Cop
      HTTP_METHODS = Set.new(%i[get post put patch delete]).freeze
      RESOURCE_METHODS = Set.new(%i[resource resources]).freeze
      ROUTE_METHODS = (HTTP_METHODS + RESOURCE_METHODS).freeze

      MSG = 'Put new routes under /-/ scope'

      def self.one_of(choices)
        "{#{choices.map(&:inspect).join(' ')}}"
      end

      def_node_matcher :path_value, <<~PATTERN
        {
          (:send nil? _ ... (hash <(pair (sym :path)(str $_)) ...>))
          (:send nil? #{one_of(HTTP_METHODS)} (str $_) ...)
          (:send nil? #{one_of(HTTP_METHODS)} (hash <(pair (str $_)(...)) ...>))
        }
      PATTERN

      def on_send(node)
        return unless route_method?(node)

        path = full_path(node)
        return if scoped_to_dash?(path)

        add_offense(node)
      end

      def full_path(node)
        path = []

        path << path_value(node)

        node.each_ancestor(:block) do |parent|
          path << path_value(parent.children[0])
        end

        path.compact.reverse.join('/')
      end

      def scoped_to_dash?(path)
        path.start_with?('-') || path.end_with?('-') || path.include?('/-/')
      end

      def route_method?(node)
        ROUTE_METHODS.include?(node.method_name)
      end

      def_node_matcher :dash_scope?, <<~PATTERN
        (:send nil? :scope (hash <(pair (sym :path)(str "groups/*group_id/-")) ...>))
      PATTERN
    end
  end
end
