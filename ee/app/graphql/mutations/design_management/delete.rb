# frozen_string_literal: true

module Mutations
  module DesignManagement
    class Delete < Base
      Errors = ::Gitlab::Graphql::Errors

      graphql_name "DesignManagementDelete"

      argument :filenames, [GraphQL::ID_TYPE],
               required: true,
               description: "The filenames of the designs to delete",
               prepare: ->(names, _ctx) do
                 names.presence || (raise Errors::ArgumentError, 'no filenames')
               end

      authorize :destroy_design

      def resolve(project_path:, iid:, filenames:)
        issue = authorized_find!(project_path: project_path, iid: iid)
        project = issue.project
        designs = resolve_designs(issue, filenames)

        result = ::DesignManagement::DeleteDesignsService
          .new(project, current_user, issue: issue, designs: designs)
          .execute

        {
          designs: [],
          errors: Array.wrap(result[:message])
        }
      end

      private

      def resolve_designs(issue, filenames)
        designs = issue.design_collection.find_all_designs_by_filename(filenames)
        deleted_designs = designs.select(&:deleted?).map(&:filename)

        if deleted_designs.empty?
          designs
        else
          msg = "The following designs have already been deleted: #{deleted_designs.join(',')}"
          raise Errors::ArgumentError, msg
        end
      end
    end
  end
end
