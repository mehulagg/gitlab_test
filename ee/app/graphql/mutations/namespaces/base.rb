# frozen_string_literal: true

module Mutations
  module Namespaces
    class Base < ::Mutations::BaseMutation
      argument :iid, GraphQL::ID_TYPE,
               required: true,
               description: "The global id of the namespace to mutate"

      field :namespace,
            Types::NamespaceType,
            null: true,
            description: 'The namespace after mutation'

      private

      def find_object(iid:)
        GitlabSchema.object_from_id(iid)
      end
    end
  end
end
