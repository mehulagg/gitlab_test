require_relative '../../migration_helpers'

module RuboCop
  module Cop
    module Migration
      # Cop that checks if remove_column is used in a regular (not
      # post-deployment) migration.
      class PostMigrationMethods < RuboCop::Cop::Cop
        include MigrationHelpers

        FORBIDDEN_METHODS = %i[remove_column change_column_null].freeze
        MSG = 'must only be used in post-deployment migrations'.freeze

        def on_def(node)
          def_method = node.children[0]

          return unless in_migration?(node) && !in_post_deployment_migration?(node)
          return unless def_method == :change || def_method == :up

          node.each_descendant(:send) do |send_node|
            send_method = send_node.children[1]

            if FORBIDDEN_METHODS.include?(send_method)
              add_offense(send_node, location: :selector, message: message(send_method))
            end
          end
        end

        private

        def message(send_method)
          "`#{send_method}` #{MSG}"
        end
      end
    end
  end
end
