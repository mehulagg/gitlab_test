# frozen_string_literal: true

module Mutations
  module Projects
    class Base < BaseMutation
      field :project,
            Types::ProjectType,
            null: false,
            description: 'The project after mutation'

      private

    end
  end
end