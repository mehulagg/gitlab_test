# frozen_string_literal: true

module Dashboard
  module Environments
    class ListService
      def initialize(user)
        @user = user
      end

      def execute
        projects_with_folders = load_projects(user)
        environments = projects_with_folders.values.flatten.map(&:last_environment)
        last_deployments = load_last_deployments(environments)
        [projects_with_folders, last_deployments]
      end

      private

      attr_reader :user

      def load_projects(user)
        projects = ::Dashboard::Operations::ProjectsService
          .new(user)
          .execute(user.ops_dashboard_projects)

        EnvironmentFolder.find_for_projects(projects)
      end

      def load_last_deployments(environments)
        return {} if environments.empty?

        last_deployments = Deployment.last_for_environment(environments)
        ActiveRecord::Associations::Preloader.new.preload(last_deployments, [:project, deployable: :user])
        last_deployments.index_by(&:environment_id)
      end
    end
  end
end
