# frozen_string_literal: true

module Projects
  module Pipelines
    class TestsController < Projects::Pipelines::ApplicationController
      before_action :validate_feature_flag!
      before_action :authorize_read_build!
      before_action :build, only: [:show]

      def summary
        respond_to do |format|
          format.json do
            render json: TestReportSummarySerializer
              .new(project: project, current_user: @current_user)
              .represent(pipeline.test_report_summary)
          end
        end
      end

      def show
        respond_to do |format|
          format.json do
            render json: TestSuiteSerializer
              .new(project: project, current_user: @current_user)
              .represent(test_suite)
          end
        end
      end

      private

      def validate_feature_flag!
        render_404 unless Feature.enabled?(:build_report_summary, project)
      end

      def tests_params
        params.permit(:id, :suite_name)
      end

      def build
        pipeline.builds.latest.find_by(name: tests_params[:suite_name])
      end

      def test_suite
        if build.present?
          build.collect_test_reports!(Gitlab::Ci::Reports::TestReports.new)
        else
          Gitlab::Ci::Reports::TestSuite.new
        end
      end
    end
  end
end
