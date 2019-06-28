# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # This migration fixes the namespaces.name for all user-namespaces that have names
    # that aren't equal to the users name.
    # Then it uses the updated names of the namespaces to update the associated routes
    # For more info see https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/23272
    class FixUserNamespaceNames
      def perform(from_id, to_id)
        fix_namespace_names(from_id, to_id)
        fix_namespace_route_names(from_id, to_id)
      end

      def fix_namespace_names(from_id, to_id)
        ActiveRecord::Base.connection.execute <<~UPDATE_NAMESPACES
          UPDATE namespaces AS update_namespaces
          SET name = (
            SELECT users.name
            FROM users
            INNER JOIN namespaces ON namespaces.owner_id = users.id
            WHERE namespaces.type IS NULL
            AND namespaces.id = update_namespaces.id
          )
          FROM namespaces
          INNER JOIN users ON namespaces.owner_id = users.id
          WHERE update_namespaces.name != users.name
          AND update_namespaces.type IS NULL
          AND update_namespaces.id BETWEEN #{from_id} AND #{to_id}
        UPDATE_NAMESPACES
      end

      def fix_namespace_route_names(from_id, to_id)
        ActiveRecord::Base.connection.execute <<~ROUTES_UPDATE
          UPDATE routes as update_routes
          SET name = (
            SELECT namespaces.name
            FROM namespaces
            INNER JOIN routes ON routes.source_id = namespaces.id
            WHERE namespaces.type IS NULL
            AND routes.source_type = 'Namespace'
            AND routes.id = update_routes.id
          )
          FROM routes
          INNER JOIN namespaces ON routes.source_id = namespaces.id
          WHERE update_routes.source_type = 'Namespace'
          AND namespaces.type IS NULL
          AND (update_routes.name != namespaces.name OR update_routes.name IS NULL)
          AND namespaces.id BETWEEN #{from_id} AND #{to_id}
        ROUTES_UPDATE
      end
    end
  end
end
