# frozen_string_literal: true

module Gitlab
  module DatabaseImporters
    module CustomDashboard
      class Importer
        MissingQueryId = Class.new(StandardError)

        PROJECT_DASHBOARD_KEY = 3

        attr_reader :content, :project

        def self.import_dashboards!(project)
          ::Metrics::Dashboard::ProjectDashboardService
            .all_dashboard_paths(project)
            .map { |attributes| new(project, attributes[:path]).execute }
        end

        def initialize(project, filename)
          @project = project
          @content = ::Metrics::Dashboard::ProjectDashboardService
                       .new(project, nil, dashboard_path: filename)
                       .raw_dashboard
        end

        def execute
          CustomDashboard::PrometheusMetric.reset_column_information

          process_content do |id, attributes|
            find_or_build_metric!(id)
              .update!(**attributes)
          end
        end

        private

        def process_content(&blk)
          content['panel_groups'].map do |group|
            process_group(group, &blk)
          end
        end

        def process_group(group, &blk)
          attributes = { group: PROJECT_DASHBOARD_KEY }

          group['panels'].map do |panel|
            process_panel(panel, attributes, &blk)
          end
        end

        def process_panel(panel, attributes, &blk)
          attributes = attributes.merge(
            title: panel['title'],
            y_label: panel['y_label'])

          panel['metrics'].map do |metric_details|
            process_metric_details(metric_details, attributes, &blk)
          end
        end

        def process_metric_details(metric_details, attributes, &blk)
          attributes = attributes.merge(
            legend: metric_details['label'],
            query: metric_details['query_range'],
            unit: metric_details['unit'])

          yield(metric_details['id'], attributes)
        end

        def find_or_build_metric!(id)
          raise MissingQueryId unless id

          CustomDashboard::PrometheusMetric.find_by(project_id: project.id, identifier: id) ||
            CustomDashboard::PrometheusMetric.new(project_id: project.id, identifier: id)
        end
      end
    end
  end
end
