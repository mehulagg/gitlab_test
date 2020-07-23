# frozen_string_literal: true

class Analytics::GroupCoverageReport
  MAX_BUILD_REPORTS = 1000.freeze

  def initialize(group:, user:, ref_path: 'refs/heads/master')
    @group = group
    @user = user
    @ref_path = ref_path
  end

  def daily_summary
    report_results.group_by(&:date).map do |date, reports|
      {
        date: date.to_s,
        builds_count: reports.count,
        projects_count: reports.uniq { |report| report.project_id }.count,
        average_coverage: reports.map { |report| report.data['coverage'].to_f }.inject(&:+) / reports.count,
        projects: reports.group_by { |report| report.project_id }.map do |project_id, reports|
          {
            project_name: project_names_by_id[project_id],
            builds: reports.map do |report|
              {
                build_name: report.group_name,
                coverage: report.data['coverage']
              }
            end
          }
        end
      }
    end
  end

  private

  def report_results
    Ci::DailyBuildGroupReportResultsFinder.new(query_params).execute.to_a
  end

  def project_names_by_id
    @project_names_by_id ||= @group.projects.select(:id, :name).each_with_object({}) do |project, hsh|
      hsh[project.id] = project.name
    end
  end

  def query_params
    {
      current_user: @user,
      projects: @group.projects,
      ref_path: @ref_path,
      start_date: 90.days.ago,
      end_date: Date.today,
      limit: MAX_BUILD_REPORTS
    }
  end
end
