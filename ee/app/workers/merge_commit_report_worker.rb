# frozen_string_literal: true

class MergeCommitReportWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include ExceptionBacktrace

  sidekiq_options retry: false

  def perform(currrent_user_id, group_id)
    current_user = User.find(current_user_id)
    group_id = Group.find(group_id)
    csv_export_job = project.export_jobs.safe_find_or_create_by(jid: self.jid)

    export_job&.start

    ::Projects::ImportExport::ExportService.new(project, current_user, params).execute(after_export)

    export_job&.finish
  rescue ActiveRecord::RecordNotFound, Gitlab::ImportExport::AfterExportStrategyBuilder::StrategyNotFoundError => e
    logger.error("Failed to export project #{project_id}: #{e.message}")
  end

  private

  def build!(after_export_strategy)
    strategy_klass = after_export_strategy&.delete('klass')

    Gitlab::ImportExport::AfterExportStrategyBuilder.build!(strategy_klass, after_export_strategy)
  end
end
