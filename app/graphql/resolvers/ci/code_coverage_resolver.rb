# frozen_string_literal: true

module Resolvers
  module Ci
    class CodeCoverageResolver < BaseResolver
      type Types::Ci::CodeCoverageType, null: true

      LIMIT = ::Projects::Ci::DailyBuildGroupReportResultsController::MAX_ITEMS.freeze
      START_DATE = 1.month.ago.freeze
      REF_PATH = 'refs/heads/master'

      alias_method :project, :object

      def resolve(**args)
        report_results = ::Ci::DailyBuildGroupReportResultsFinder.new(finder_params).execute

        ::Ci::CodeCoverage.new(report_results: report_results)
      end

      private

      def finder_params
        {
          current_user: current_user,
          project: project,
          ref_path: REF_PATH,
          start_date: START_DATE,
          end_date: Date.today,
          limit: LIMIT
        }
      end
    end
  end
end
