# frozen_string_literal: true

module Ci
  class CreatePipelineScheduleService < ::ContainerBaseService
    def execute
      project.pipeline_schedules.create(pipeline_schedule_params)
    end

    private

    def pipeline_schedule_params
      params.merge(owner: current_user)
    end
  end
end
