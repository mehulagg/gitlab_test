# frozen_string_literal: true

module Ci
  class DailyBuildGroupReportResultsFinder
    include Gitlab::Allowable

    def initialize(current_user:, projects:, ref_path:, start_date:, end_date:, limit: nil)
      @current_user = current_user
      @projects = [projects].flatten
      @ref_path = ref_path
      @start_date = start_date
      @end_date = end_date
      @limit = limit
    end

    def execute
      return none unless projects.all? { |project| can?(current_user, :read_build_report_results, project) }

      Ci::DailyBuildGroupReportResult.recent_results(
        query_params,
        limit: limit
      )
    end

    private

    attr_reader :current_user, :projects, :ref_path, :start_date, :end_date, :limit

    def query_params
      {
        project_id: projects,
        ref_path: ref_path,
        date: start_date..end_date
      }
    end

    def none
      Ci::DailyBuildGroupReportResult.none
    end
  end
end
