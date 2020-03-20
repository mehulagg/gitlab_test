# frozen_string_literal: true

# TODO: Do we move this out of :development? Is there a better way to do this?
require 'json-schema'

module Gitlab
  module DatabaseImporters
    module CustomDashboard
      # Imports source-controlled project dashboards into the DB.
      # Skips any metrics without an 'id' defined & aren't line graphs.
      class Importer
        InvalidDashboardError = Class.new(StandardError)

        PROJECT_DASHBOARD_KEY = 3
        DASHBOARD_SCHEMA_PATH = 'lib/gitlab/metrics/dashboard/schemas/raw/dashboard.json'.freeze

        attr_reader :content, :project
        attr_accessor :identifiers

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
          @identifiers = []
        end

        def execute
          CustomDashboard::PrometheusMetric.reset_column_information

          validate_dashboard!

          process_content do |id, attributes|
            find_or_build_metric!(id)
              .update!(**attributes)
          end

          cleanup_unidentified_metrics
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
          return unless %w(area-chart line-chart).include?(panel['type'])

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
            query: metric_details['query_range'] || metric_details['query'],
            unit: metric_details['unit'])

          yield(metric_details['id'], attributes)
        end

        def find_or_build_metric!(id)
          return unless id
          identifiers << id

          CustomDashboard::PrometheusMetric.find_by(project_id: project.id, identifier: id) ||
            CustomDashboard::PrometheusMetric.new(project_id: project.id, identifier: id)
        end

        def cleanup_unidentified_metrics
          CustomDashboard::PrometheusMetric
            .where(project_id: project.id, group: PROJECT_DASHBOARD_KEY)
            .where.not(identifier: identifiers)
            .destroy_all
        end

        def validate_dashboard!
          raw_schema = File.read(Rails.root.join(DASHBOARD_SCHEMA_PATH))
          schema = JSON.parse(raw_schema)

          errors = JSON::Validator.fully_validate(schema, content)

          raise InvalidDashboardError.new(errors) unless errors.empty?
        end
      end
    end
  end
end
