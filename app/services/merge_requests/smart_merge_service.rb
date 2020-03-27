# frozen_string_literal: true

module MergeRequests
  # This service is compatible with both immediate and auto merge strategy.
  class SmartMergeService < ::BaseService
    def execute(merge_request)
      result = validate(merge_request)

      return result unless result[:status] == :success

      reset_merge_attributes(merge_request)

      if auto_merge_requested?
        ::AutoMergeService.new(project, current_user, params).execute(merge_request)
      else
        merge_request.merge_async(current_user.id, params)
        success(strategy: :merge)
      end
    end

    private

    def validate(merge_request)
      # Disable the CI check if auto_merge_strategy is specified since we have
      # to wait until CI completes to know
      unless merge_request.mergeable?(skip_ci_check: auto_merge_requested?)
        return error(error_code: :failed)
      end

      merge_service = ::MergeRequests::MergeService.new(@project, current_user, params)

      unless merge_service.hooks_validation_pass?(merge_request)
        return error(error_code: :hook_validation_error)
      end

      unless params[:sha] != merge_request.diff_head_sha
        return error(error_code: :sha_mismatch)
      end

      success
    end

    def reset_merge_attributes(merge_request)
      merge_request.update_column(merge_error: nil, squash: params.fetch(:squash, false))
    end

    def auto_merge_requested?
      params[:auto_merge_strategy].present?
    end
  end
end
