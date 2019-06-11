# frozen_string_literal: true

module Types
  module DesignManagement
    class VersionType < BaseObject
      # Just `Version` might be a bit to general to expose globally so adding
      # a `Design` prefix to specify the class exposed in GraphQL
      graphql_name 'DesignVersion'

      authorize :read_design

      field :sha, GraphQL::ID_TYPE, null: false
      field :image, GraphQL::STRING_TYPE, null: true, extras: [:parent]
      field :designs,
            Types::DesignManagement::DesignType.connection_type,
            null: false,
            description: "All designs that were changed in this version"

      def image(parent:)
        if (design = find_first_design_from_parents(parent))
          Gitlab::Routing.url_helpers.project_design_url(design.project, design, ref: sha)
        end
      end

      # As a version can have many designs, search up the GraphQL AST to
      # find a DesignType parent of this node.
      def find_first_design_from_parents(parent)
        while parent.respond_to?(:parent)
          return parent.object.node if parent.type.name == DesignType.graphql_name

          parent = parent.parent
        end
      end
    end
  end
end
