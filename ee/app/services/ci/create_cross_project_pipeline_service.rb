# frozen_string_literal: true

module Ci
  # TODO: rename this (and worker) to CreateDownstreamPipelineService
  class CreateCrossProjectPipelineService < ::BaseService
    include Gitlab::Utils::StrongMemoize

    def execute(bridge)
      @bridge = bridge

      return unless ensure_preconditions!

      pipeline_params = @bridge.downstream_pipeline_params

      service = ::Ci::CreatePipelineService.new(
        pipeline_params.fetch(:project),
        current_user,
        pipeline_params.fetch(:target_revision))

      service.execute(
        pipeline_params.fetch(:source),
        { ignore_skip_ci: true }.merge(pipeline_params[:other_execute_params] || {})) do |pipeline|
          @bridge.sourced_pipelines.build(
            source_pipeline: @bridge.pipeline,
            source_project: @bridge.project,
            project: @bridge.downstream_project,
            pipeline: pipeline)

          pipeline.variables.build(@bridge.downstream_variables)
        end
    end

    private

    def ensure_preconditions!
      unless downstream_project_accessible?
        @bridge.drop!(:downstream_bridge_project_not_found)
        return false
      end

      # TODO: Remove this condition if favour of model validation
      # https://gitlab.com/gitlab-org/gitlab/issues/38338
      if downstream_project == project && !@bridge.triggers_child_pipeline?
        @bridge.drop!(:invalid_bridge_trigger)
        return false
      end

      unless can_create_downstream_pipeline?
        @bridge.drop!(:insufficient_bridge_permissions)
        return false
      end

      true
    end

    def downstream_project_accessible?
      downstream_project.present? &&
        can?(current_user, :read_project, downstream_project)
    end

    def can_create_downstream_pipeline?
      can?(current_user, :update_pipeline, project) &&
        can?(current_user, :create_pipeline, downstream_project)
    end

    def downstream_project
      strong_memoize(:downstream_project) do
        @bridge.downstream_project
      end
    end
  end
end
