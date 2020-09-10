# frozen_string_literal: true

module Resolvers
  module Ci
    class DailyBuildGroupReportResultResolver < BaseResolver
      type Types::Ci::DailyBuildGroupReportResultType, null: true

      alias_method :project, :object

      def resolve(**args)
        ::Ci::DailyBuildGroupReportResultsFinder.new(finder_params).execute
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
