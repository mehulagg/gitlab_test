# frozen_string_literal: true

module Types
  module DesignManagement
    # rubocop: disable Graphql/AuthorizeTypes
    class DesignConnectionType < GraphQL::Types::Relay::BaseConnection
      field :total_count, Integer, null: false,
            description: 'Total count of designs in design collection'

      def total_count
        return 0 unless Ability.allowed?(context[:current_user], :read_design, object.parent)

        object.nodes.size
      end
    end
  end
end
