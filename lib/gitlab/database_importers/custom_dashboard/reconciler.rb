# frozen_string_literal: true

module Gitlab
  module DatabaseImporters
    module CustomDashboard
      # Responsible for removing metrics orphaned in the import process.
      # When dashboards are re-imported, there is a chance that metrics
      # have been removed from the dashboard. This class is responsible
      # for removing these metrics from the database.
      class Reconciler
        include StrongMemoize

        PROJECT_DASHBOARD_GROUP = 3

        attr_reader :project, :identifiers

        # Warning! The reconciler works on a project basis, so
        # a set of identifiers for a single dashboard should not
        # be passed as the `identifiers` argument.
        #
        # @param project [Project] Project for which metrics have been ingested
        # @param identifiers [Array<String>] DB identifiers for all dashboard
        #                      metrics which have been ingested for the project
        def initialize(project, identifiers)
          @project = project
          @identifiers = identifiers
        end

        def execute
          reconcile_metrics!
          reconcile_alerts!
          reconcile_environments!
        end

        private

        def reconcile_metrics!
          impacted_metrics.destroy_all
        end

        def reconcile_alerts!
          impacted_alerts.destroy_all
        end

        def reconcile_environments!
          impacted_environments.each do |environment|
            schedule_prometheus_update!(environment)
          end
        end

        def impacted_metrics
          strong_memoize(:impacted_metrics) do
            CustomDashboard::PrometheusMetric
              .where(project_id: project.id, group: PROJECT_DASHBOARD_GROUP)
              .where.not(identifier: identifiers)
          end
        end

        def impacted_alerts
          strong_memoize(:impacted_alerts) do
            Projects::Prometheus::AlertFinder.new(
              project: project,
              metric: impacted_metrics
            ).execute.includes(:environment)
          end
        end

        def impacted_environments
          impacted_alerts.map(&:environment).uniq
        end

        def schedule_prometheus_update!(environment)
          ::Clusters::Applications::ScheduleUpdateService.new(
            environment.cluster_prometheus_adapter,
            project
          ).execute
        end
      end
    end
  end
end
