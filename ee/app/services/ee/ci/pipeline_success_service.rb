# frozen_string_literal: true

module EE
  module Ci
    module PipelineSuccessService
      extend ::Gitlab::Utils::Override

      def execute(pipeline)
        MergeRequests::MergeTrainService.new(project, nil)
                                        .merge_train_for(pipeline)
      end
    end
  end
end
