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

      def load_projects(user)
        dashboard_project_ids = user.users_ops_dashboard_projects.pluck(:project_id)
        projects = ::Dashboard::Operations::ProjectsService
          .new(user)
          .execute(dashboard_project_ids)
          .take(7)

        projects
      end
    end
  end
end
