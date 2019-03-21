# frozen_string_literal: true

module Ci
  class CreateCrossProjectPipelineWorker
    include ::ApplicationWorker
    include ::PipelineQueue

    def perform(bridge_id)
      ::Ci::Bridges::DownstreamBridge.find_by_id(bridge_id).try do |bridge|
        ::Ci::CreateDownstreamPipelineService
          .new(bridge.project, bridge.user)
          .execute(bridge)
      end
    end
  end
end
