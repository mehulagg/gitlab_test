# frozen_string_literal: true

class MergeRequest
  class PipelineCompletedListener
    def self.handle_event(event, data)
      pipeline = Ci::Pipeline.find_by_id(data[:pipeline_id])
      return unless pipeline

      pipeline.all_merge_requests.each do |merge_request|
        next unless merge_request.auto_merge_enabled?

        # Workers should be allowed to be used inside listeners
        AutoMergeProcessWorker.perform_async(merge_request.id) # rubocop: disable CodeReuse/Worker
      end
    end
  end
end
