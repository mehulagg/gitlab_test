# frozen_string_literal: true

module MergeTrains
  class ProcessWorker
    include ApplicationWorker

    queue_namespace :merge_train

    def perform(merge_request_id)
      MergeRequest.find_by_id(merge_request_id).try do |merge_request|
        MergeTrain.process(merge_request)
      end
    end
  end
end
