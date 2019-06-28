# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # This migration fixes the routes.name for all user-projects that have names
    # that don't start with the users name.
    # For more info see https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/23272
    class FixUserProjectRouteNames
      def perform(from_id, to_id)
        ActiveRecord::Base.connection.execute <<~ROUTES_UPDATE
          UPDATE routes as update_routes
          SET name = (
            SELECT users.name || ' / ' || projects.name
            FROM routes
            INNER JOIN projects ON routes.source_id = projects.id
            INNER JOIN namespaces ON projects.namespace_id = namespaces.id
            INNER JOIN users ON users.id = namespaces.owner_id
            WHERE namespaces.type IS NULL AND routes.id = update_routes.id
            AND routes.source_type = 'Project'
          )
          FROM routes
          INNER JOIN projects ON routes.source_id = projects.id
          INNER JOIN namespaces ON projects.namespace_id = namespaces.id
          INNER JOIN users ON namespaces.owner_id = users.id
          WHERE update_routes.source_type = 'Project'
          AND namespaces.type IS NULL
          AND (update_routes.name NOT LIKE users.name || '%' OR update_routes.name IS NULL)
          AND update_routes.id BETWEEN #{from_id} AND #{to_id}
        ROUTES_UPDATE
      end
    end
  end
end
