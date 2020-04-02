# frozen_string_literal: true

module Resolvers
  module Projects
    class JiraImportsResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource

      alias_method :project, :object

      def resolve(**args)
        raise_resource_not_available_error! unless project || Feature.enabled?(:jira_issue_import, project)
        return JiraImportData.none unless project&.import_data.present?

        authorize!(project)

        project.import_data.becomes(JiraImportData).projects
      end

      def authorized_resource?(project)
        Ability.allowed?(context[:current_user], :admin_project, project)
      end
    end
  end
end
