# frozen_string_literal: true

module Gitlab
  module GithubImport
    # The ParallelImporter schedules the importing of a GitHub project using
    # Sidekiq.
    class ParallelImporter
      attr_reader :project

      def self.async?
        true
      end

      def self.imports_repository?
        true
      end

      def initialize(project)
        @project = project
      end

      def execute
        Gitlab::Import::SetAsyncJid.set_jid(project.import_state)

        Stage::ImportRepositoryWorker
          .perform_async(project.id)

        true
      end
    end
  end
end

Gitlab::GithubImport::ParallelImporter.prepend_if_ee('::EE::Gitlab::GithubImport::ParallelImporter')
