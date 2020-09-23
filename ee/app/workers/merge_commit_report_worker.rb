# frozen_string_literal: true

class MergeCommitReportWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include ExceptionBacktrace

  sidekiq_options retry: false

  def perform(current_user_id, group_id)
    current_user = User.find(current_user_id)
    group = Group.find(group_id)
    csv_export_job = current_user.csv_export_jobs.safe_find_or_create_by(jid: self.jid, export_type: 1)

    csv_export_job&.start

    exporter(current_user, group).csv_data { |f| csv_export_job.file = f }
    csv_export_job.file.filename = 'merge_commits_csv_test'

    csv_export_job&.finish
  rescue StandardError => e
    logger.error("Failed to export merge_commit_report csv: #{e.message}")
  end

  private

  def exporter(current_user, group)
    MergeCommits::ExportCsvService.new(current_user, group)
  end
end
