# frozen_string_literal: true

module RuboCop
  module Cop
    module Gitlab
      class Json < RuboCop::Cop::Cop
        MSG_SEND = <<~EOL.freeze
          Avoid calling `JSON` directly. Instead, use the Gitlab::Json
          wrapper. This allows us to alter the JSON parser being used.
        EOL

        MSG_INCLUDE = <<~EOL.freeze
          Avoid calling `JSON` directly. Instead, use the Gitlab::Json
          wrapper. This allows us to alter the JSON parser being used.
        EOL

        def_node_matcher :includes_json?, <<~PATTERN
          (send nil? :include (const nil? :JSON))
        PATTERN

        def_node_matcher :json_node?, <<~PATTERN
          (send (const nil? :JSON)...)
        PATTERN

        def on_send(node)
          add_offense(node, location: :expression, message: MSG_SEND) if json_node?(node)
          add_offense(node, location: :expression, message: MSG_INCLUDE) if includes_json?(node)
        end

        def autocorrect(node)
          if includes_json?(node)
            autocorrect_includes_json(node)
          else
            autocorrect_json_node(node)
          end
        end

        def autocorrect_includes_json(node)
          lambda do |corrector|
            corrector.remove(node.source_range)
          end
        end

        def autocorrect_json_node(node)
          _, method_name, *arg_nodes = *node

          replacement = "Gitlab::Json.#{method_name}(#{arg_nodes.map(&:source).join(', ')})"

          lambda do |corrector|
            corrector.replace(node.source_range, replacement)
          end
        end
      end
    end
  end
end
