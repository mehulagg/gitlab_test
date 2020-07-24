# frozen_string_literal: true

class Groups::Analytics::CoverageReportsController < Groups::Analytics::ApplicationController
  check_feature_flag Gitlab::Analytics::CYCLE_ANALYTICS_FEATURE_FLAG

  before_action :load_group
  before_action -> { check_feature_availability!(:group_coverage_reports) }

  def index
    @summary = Analytics::GroupCoverageReport.new(group: @group, user: current_user).daily_summary

    respond_to do |format|
      format.json { render json: @summary.to_json }
      format.csv { send_data([].to_csv, type: 'text/csv; charset=utf-8') }
    end
  end
end
