# frozen_string_literal: true

module EE
  module Gitlab
    module Analytics
      module ValueStreamAnalytics
        module DataCollector
          def duration_chart_data
            strong_memoize(:duration_chart) do
              ::Gitlab::Analytics::ValueStreamAnalytics::DataForDurationChart.new(stage: stage, query: query).load
            end
          end
        end
      end
    end
  end
end
