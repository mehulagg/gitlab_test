# frozen_string_literal: true

module Gitlab
  module ImportExport
    module V0_2_5 # rubocop:disable Naming/ClassAndModuleCamelCase
      # Given a class, it finds or creates a new object
      # (initializes in the case of Label) at group or project level.
      # If it does not exist in the group, it creates it at project level.
      #
      # Example:
      #   `GroupProjectObjectBuilder.build(Label, label_attributes)`
      #    finds or initializes a label with the given attributes.
      #
      # It also adds some logic around Group Labels/Milestones for edge cases.
      class GroupProjectObjectBuilder < Gitlab::ImportExport::GroupProjectObjectBuilder
        extend ::Gitlab::Utils::Override

        private

        # Returns Arel clause `"{table_name}"."project_id" = {project.id}` if project is present
        # For example: merge_request has :target_project_id, and we are searching by :iid
        # or, if group is present:
        # `"{table_name}"."project_id" = {project.id} OR "{table_name}"."group_id" = {group.id}`
        override :where_clause_base
        def where_clause_base
          clause = table[:project_id].eq(project.id) if project
          clause = clause.or(table[:group_id].eq(group.id)) if group

          clause
        end

        protected

        # Returns Arel clause for a particular model or `nil`.
        # Search already created merge_request by 'iid'
        def where_clause_for_klass
          return attrs_to_arel(attributes.slice('iid')) if merge_request?
        end
      end
    end
  end
end
