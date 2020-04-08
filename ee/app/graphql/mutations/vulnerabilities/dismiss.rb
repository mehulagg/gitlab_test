# frozen_string_literal: true

module Mutations
  module Vulnerabilities
    class Dismiss < BaseMutation
      graphql_name 'dismissVulnerability'

      authorize :admin_vulnerability

      field :vulnerability, Types::VulnerabilityType,
            null: true,
            description: 'The vulnerability after dismissal'

      argument :id,
               GraphQL::ID_TYPE,
               required: true,
               description: 'The id of the vulnerability to be dismissed'

      argument :comment,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'The reason why vulnerability should be dismissed'

      def resolve(id:, comment:)
        vulnerability = authorized_find!(id: id)
        service = dismiss_vulnerability(vulnerability, comment)

        {
          vulnerability: vulnerability.reset,
          errors: service.errors.full_messages || []
        }
      end

      private

      def dismiss_vulnerability(vulnerability, comment)
        ::Vulnerabilities::DismissService.new(current_user, vulnerability, comment).execute
      end

      def find_object(id:)
        GitlabSchema.object_from_id(id)
      end
    end
  end
end
