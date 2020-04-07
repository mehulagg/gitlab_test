# frozen_string_literal: true

module Gitlab
  module DatabaseImporters
    module CustomDashboard
      # Imports source-controlled project dashboards into the DB.
      #
      # Skips any metrics without an 'id' defined or aren't
      # currently supported panel types.
      #
      # If a failure should occur partway, a partial import will occur.
      class Importer
        PROJECT_DASHBOARD_GROUP = 3
        SUPPORTED_PANEL_TYPES = {
          'area-chart' => CustomDashboard::PanelType::TimeSeries,
          'line-chart' => CustomDashboard::PanelType::TimeSeries
        }.freeze

        attr_reader :content, :project

        # Imports all custom dashboards for a project, removing
        # any custom dashboard metrics (and corresponding alerts)
        # from the DB which are not present in the current dashboards.
        #
        # Does not impact common metrics or custom metrics
        # added through the UI.
        #
        # @param project [Project]
        def self.import_dashboards!(project)
          all_identifiers = ::Metrics::Dashboard::ProjectDashboardService
                              .all_dashboard_paths(project)
                              .flat_map { |attributes| new(project, attributes[:path]).execute }

          CustomDashboard::Reconciler.new(project, all_identifiers).execute
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
          CustomDashboard::Validator.new(content).execute

          process_content do |id, attributes|
            find_or_build_metric!(id)
              .update!(**attributes)
          end

          identifiers
        end

        private

        def process_content(&blk)
          content['panel_groups'].map do |group|
            process_group(group, &blk)
          end
        end

        def process_group(group, &blk)
          attributes = { group: PROJECT_DASHBOARD_GROUP }

          group['panels'].map do |panel|
            process_panel(panel, attributes, &blk)
          end
        end

        def process_panel(panel, attributes, &blk)
          panel_config = SUPPORTED_PANEL_TYPES[panel['type']]
          return unless panel_config

          panel_attributes = panel_config.get_panel_attributes(panel)
          attributes = attributes.merge(panel_attributes)

          panel['metrics'].map do |metric_details|
            process_metric(panel_config, metric_details, attributes, &blk)
          end
        end

        def process_metric(panel_config, metric_details, attributes, &blk)
          metric_attributes = panel_config.get_metric_attributes(metric_details)
          attributes = attributes.merge(metric_attributes)

          yield(metric_details['id'], attributes)
        end

        def find_or_build_metric!(id)
          return unless id
          add_identifier(id)

          CustomDashboard::PrometheusMetric.find_by(project_id: project.id, identifier: id) ||
            CustomDashboard::PrometheusMetric.new(project_id: project.id, identifier: id)
        end

        def add_identifier(id)
          @identifiers << id
        end
      end
    end
  end
end
