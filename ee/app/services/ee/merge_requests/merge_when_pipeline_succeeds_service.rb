# frozen_string_literal: true

module EE
  module MergeRequests
    module MergeWhenPipelineSucceedsService
      extend ::Gitlab::Utils::Override

      override :trigger
      def trigger(pipeline)
        enqueue_merge_request_to_train(pipeline) || super
      end

      private

      def enqueue_merge_request_to_train(pipeline)
        return unless pipeline.merge_request_pipeline?
        return unless merge_request.merge_when_pipeline_succeeds?

        MergeRequests::MergeTrainService
          .new(project, user).enqueue(pipeline.merge_request)
      end
    end
  end
end
