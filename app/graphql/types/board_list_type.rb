# frozen_string_literal: true

module Types
  class BoardListType < BaseObject
    graphql_name 'BoardList'
    description 'Represents a list for an issue board'

    # authorize :read_board

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID (global ID) of the board list'
    field :label, Types::LabelType, null: true,
          description: 'Label of the board list'
    field :position, GraphQL::INT_TYPE, null: true,
          description: 'Position of list within the board'
  end
end

Types::BoardListType.prepend_if_ee('::EE::Types::BoardListType')
