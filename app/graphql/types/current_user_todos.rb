# frozen_string_literal: true

# Interface to expose todos for the current_user on the `object`
module Types
  module CurrentUserTodos
    include BaseInterface

    STATES_ARG_ERROR = 'The states argument cannot be an empty Array. ' \
                       'Consider omitting the argument instead'

    field_class Types::BaseField

    field :current_user_todos, Types::TodoType.connection_type,
          description: 'Todos for the current user',
          null: false do
            argument :states, [Types::TodoStateEnum],
                     description: 'States of the todos',
                     required: false,
                     prepare: ->(states, _ctx) do
                       next if states.nil? # Allow `null` if specifically given

                       states.presence || (raise Gitlab::Graphql::Errors::ArgumentError, STATES_ARG_ERROR)
                     end
          end

    def current_user_todos(states: nil)
      states ||= %i(done pending) # TodosFinder treats a `nil` state param as `pending`

      TodosFinder.new(current_user, state: states, type: object.class.name, target_id: object.id).execute
    end
  end
end
