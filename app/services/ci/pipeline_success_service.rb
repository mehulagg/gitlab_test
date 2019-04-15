# frozen_string_literal: true

module Ci
  class PipelineSuccessService < BaseService
    def execute(pipeline)
      MergeRequests::MergeWhenPipelineSucceedsService
        .new(project, nil)
        .trigger(pipeline)
    end
  end
end

Ci::PipelineSuccessService.prepend(EE::Ci::PipelineSuccessService)