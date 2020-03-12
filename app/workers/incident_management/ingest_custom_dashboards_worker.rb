# frozen_string_literal: true

module IncidentManagement
  class IngestCustomDashboardsWorker
    include ApplicationWorker

    feature_category :incident_management

    def perform(project_id)
      project = find_project(project_id)
      return unless project

      ::Gitlab::DatabaseImporters::CustomDashboard::Importer.import_dashboards!(project)
    end

    private

    def find_project(project_id)
      Project.find_by_id(project_id)
    end
  end
end
