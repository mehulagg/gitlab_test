# frozen_string_literal: true

module Dashboard
  module Environments
    class ListService
      def initialize(user)
        @user = user
      end

      def execute
        load_projects(user)
      end

      private

      attr_reader :user

      # rubocop: disable CodeReuse/ActiveRecord
      def load_projects(user)
        dashboard_project_ids = user.users_ops_dashboard_projects.pluck(:project_id)
        projects = ::Dashboard::Operations::ProjectsService
          .new(user)
          .execute(dashboard_project_ids)
          .take(7)

        ActiveRecord::Associations::Preloader.new.preload(projects, [
          :route,
          environments_for_dashboard: [
            :last_visible_pipeline,
            last_visible_deployment: [:deployable, project: [namespace: :route]],
            project: [:project_feature, :group, namespace: :route]
          ],
          namespace: [:route, :owner]
        ])

        projects
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
