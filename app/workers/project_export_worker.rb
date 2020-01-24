# frozen_string_literal: true

class ProjectExportWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include ExceptionBacktrace
  include ProjectExportOptions

  feature_category :importers
  worker_resource_boundary :memory

  def perform(current_user_id, project_id, after_export_strategy = {}, params = {})
    current_user = User.find(current_user_id)
    project = Project.find(project_id)
    export_job = ::Projects::ExportJobs::CreateService.new(project).execute(self.jid)
    after_export = build!(after_export_strategy)

    ::Projects::ImportExport::ExportService.new(project, current_user, params).execute(after_export)

    ::Projects::ExportJobs::FinishService.new(project).execute(export_job)
  end

  private

  def build!(after_export_strategy)
    strategy_klass = after_export_strategy&.delete('klass')

    Gitlab::ImportExport::AfterExportStrategyBuilder.build!(strategy_klass, after_export_strategy)
  end
end
