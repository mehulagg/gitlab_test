# frozen_string_literal: true
class Groups::Security::MergeCommitReportsController < Groups::ApplicationController
  include Groups::SecurityFeaturesHelper
  include SendFileUpload

  before_action :authorize_compliance_dashboard!

  def index
    MergeCommitReportWorker.perform_async(current_user.id, group.id)

    redirect_to(
      group_security_compliance_dashboard_path(group),
      notice: _("Export started")
    )
  end

  def download_export
    export_file = current_user.csv_export_jobs.where(export_type: 1, status: 2).last
    if export_file.present?
      send_upload(export_file.file, attachment: export_file.file.filename)
    else
      redirect_to(
        group_security_compliance_dashboard_path(group),
        alert: _("Merge Commit export link has expired. Please generate a new export")
      )
    end
  end

  private

  def merge_commits_csv_filename
    "#{group.id}-merge-commits-#{Time.current.to_i}.csv"
  end
end
