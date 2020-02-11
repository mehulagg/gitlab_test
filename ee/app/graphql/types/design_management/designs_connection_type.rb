# frozen_string_literal: true

module Types
  module DesignManagement
    class DesignsConnectionType < GraphQL::Types::Relay::BaseConnection
      edge_type(Types::DesignManagement::DesignType.edge_type)

      authorize :read_design

      field :total_count, Integer, null: false,
            description: 'Total count of designs in design collection'

      def total_count
        object.nodes.size
      end
    end
  end
end
