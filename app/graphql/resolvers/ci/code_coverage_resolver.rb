# frozen_string_literal: true

module Resolvers
  module Ci
    class CodeCoverageResolver < BaseResolver
      type Types::Ci::CodeCoverageType, null: true

      alias_method :project, :object

      def resolve(**args)
        report_results = ::Ci::DailyBuildGroupReportResultsFinder.new(finder_params).execute

        ::Ci::CodeCoverage.new(report_results: report_results)
      end

      def finder_params
        {
          current_user: current_user,
          project: project,
          ref_path: 'master',
          start_date: 1.month.ago,
          end_date: Date.today,
          limit: 10
        }
      end
    end
  end
end
