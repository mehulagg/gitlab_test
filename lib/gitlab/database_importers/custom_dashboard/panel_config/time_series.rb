# frozen_string_literal: true

module Gitlab
  module DatabaseImporters
    module CustomDashboard
      module PanelConfig
        class TimeSeries
          class << self
            # Returns the formatted attributes from a panel which are
            # required to create a Prometheus Metric in the DB
            #
            # @param panel [Hash] Represents a panel from a yml dashboard
            def get_panel_attributes(panel)
              {
                title: panel['title'],
                y_label: panel['y_label']
              }
            end

            # Returns the formatted attributes from a metric which are
            # required to create a Prometheus Metric in the DB
            #
            # @param metric [Hash] Represents a metric from a yml dashboard
            def get_metric_attributes(metric)
              {
                legend: metric['label'],
                query: metric['query_range'] || metric['query'],
                unit: metric['unit']
              }
            end
          end
        end
      end
    end
  end
end
