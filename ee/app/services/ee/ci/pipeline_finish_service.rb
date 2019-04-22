# frozen_string_literal: true

module EE
  module Ci
    module PipelineFinishService
      def execute(pipeline)
        shift_merge_train(pipeline)
      end

      private

      def shift_merge_train(pipeline)
        return unless pipeline.merge_request

        ::MergeRequests::MergeTrainService.new(project, user)
          .finalize(pipeline.merge_request)
      end
    end
  end
end
