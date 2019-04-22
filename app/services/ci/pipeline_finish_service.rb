# frozen_string_literal: true

module Ci
  class PipelineFinishService
    def execute(pipeline)
      # no-op
    end
  end
end

Ci::PipelineFinishService.prepend(EE::Ci::PipelineFinishService)
