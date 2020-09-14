# frozen_string_literal: true

module Projects
  class BulkUpdateStatisticsService
    def initialize(deltas_by_project, statistic:)
      @deltas_by_project = deltas_by_project
      @statistic = statistic
    end

    def execute
      update_projects_statistics
      update_namespaces_statistics

      true
    end

    private

    attr_reader :deltas_by_project
    attr_reader :statistic

    def update_projects_statistics
      deltas_by_project.each do |project, delta|
        next unless project

        ProjectStatistics.increment_statistic(project.id, statistic, delta)
      end
    end

    def update_namespaces_statistics
      projects = deltas_by_project.keys.compact

      if projects.size == 1
        Namespaces::ScheduleAggregationWorker.perform_async(projects.first.namespace_id)
      else
        Namespaces::ScheduleAggregationWorker
          .bulk_perform_async_with_contexts(projects,
            arguments_proc: -> (project) { project.namespace_id },
            context_proc: -> (project) { { project: project } }
          )
      end
    end
  end
end
