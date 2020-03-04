# frozen_string_literal: true

module Gitlab
  module JiraImport
    class ImporterWorker # rubocop:disable Scalability/IdempotentWorker
      include ApplicationWorker
      include ExceptionBacktrace
      include ProjectStartImport
      include ProjectImportOptions

      queue_namespace :jira_importer
      feature_category :importers
      worker_has_external_dependencies!

      def perform(project_id)
        @project = Project.find(project_id)

        return unless start_import

        service = Gitlab::Jira::Importer.new(project)
        service.execute
      end

      private

      attr_reader :project

      def start_import
        return true if start(project.import_state)

        Rails.logger.info("Project #{project.full_path} was in inconsistent state (#{project.import_status}) while importing.") # rubocop:disable Gitlab/RailsLogger
        false
      end
    end
  end
end
