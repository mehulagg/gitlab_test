# frozen_string_literal: true

module Gitlab
  module GithubImport
    # AdvanceStageWorker is a worker used by the GitHub importer to wait for a
    # number of jobs to complete, without blocking a thread. Once all jobs have
    # been completed this worker will advance the import process to the next
    # stage.
    class AdvanceStageWorker # rubocop:disable Scalability/IdempotentWorker
      include ApplicationWorker
      include ::Gitlab::Import::AdvanceStage

      sidekiq_options dead: false
      feature_category :importers
      loggable_arguments 1, 2

      # The known importer stages and their corresponding Sidekiq workers.
      STAGES = {
        issues_and_diff_notes: Stage::ImportIssuesAndDiffNotesWorker,
        notes: Stage::ImportNotesWorker,
        lfs_objects: Stage::ImportLfsObjectsWorker,
        finish: Stage::FinishImportWorker
      }.freeze

      # Gitea importer stages. Gitea does not support pull request comments. For this reason
      # ImportIssuesAndDiffNotesWorker needs to be left out from import process.
      GITEA_STAGES = {
        issues: Stage::ImportIssuesWorker,
        notes: Stage::ImportNotesWorker,
        lfs_objects: Stage::ImportLfsObjectsWorker,
        finish: Stage::FinishImportWorker
      }.freeze

      def find_import_state(project_id)
        ProjectImportState.jid_by(project_id: project_id, status: :started)
      end

      private

      def next_stage_worker(next_stage, project_id)
        project = Project.find(project_id)

        if project.gitea_import?
          GITEA_STAGES.fetch(next_stage.to_sym)
        else
          STAGES.fetch(next_stage.to_sym)
        end
      end
    end
  end
end
