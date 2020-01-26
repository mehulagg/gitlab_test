# frozen_string_literal: true

module Git
  module Logger
    def log_error(exception:, message:, save_message_on_model: false)
      reference = merge_request.to_reference(full: true)
      data = {
        class: self.class.name,
        message: message,
        merge_request_id: merge_request.id,
        merge_request: reference,
        save_message_on_model: save_message_on_model
      }

      if exception
        Gitlab::ErrorTracking.track_exception(exception, data)
        data[:"exception.message"] = exception.message
      end

      # TODO: Deprecate Gitlab::GitLogger since ErrorTracking should suffice
      data[:message] = "#{self.class.name} error (#{reference}): #{message}"
      Gitlab::GitLogger.error(data)

      merge_request.update(merge_error: message) if save_message_on_model
    end
  end
end
