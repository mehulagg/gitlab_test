# frozen_string_literal: true

module MergeRequests
  class CreatePipelineService < MergeRequests::BaseService
    def create_pipeline_for(merge_request)
      rate_limit(merge_request) do
        super
      end
    end

    private

    def rate_limit(merge_request)
      return unless merge_request && current_user

      limiter = ::Gitlab::ActionRateLimiter.new(action: :create_pipeline_for_merge_request)

      return unless limiter.throttled?([current_user, merge_request], 1)

      yield
    end
  end
end
