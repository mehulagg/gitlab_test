# frozen_string_literal: true

module Gitlab
  module JiraImport
    class ImportIssuesWorker # rubocop:disable Scalability/IdempotentWorker
      include ApplicationWorker
      include ExceptionBacktrace
      include ProjectStartImport
      include ProjectImportOptions

      queue_namespace :jira_importer
      feature_category :importers

      def perform(project_id)
        @project = Project.find(project_id)

        return unless start_import

        importer = Gitlab::JiraImport::BaseImporter.new(project)
        importer.execute
      end

      private

      attr_reader :project

      def start_import
        return true if start(project.import_state)

        Gitlab::AppLogger.info("Project #{project.full_path} was in inconsistent state (#{project.import_status}) while importing.")
        false
      end
    end
  end
end
