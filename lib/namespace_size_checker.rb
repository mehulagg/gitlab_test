# frozen_string_literal: true

module Gitlab
  class NamespaceSizeChecker
    attr_reader :limit, :namespace

    def initialize(current_size_proc:, limit:, namespace:, enabled: true)
      @current_size_proc = current_size_proc
      @limit = limit
      @enabled = enabled && limit != 0
      @namespace = namespace
    end

    def current_size
      @current_size ||= @current_size_proc.call
    end

    def enabled?
      @enabled
    end

    def usage_ratio
      return 0 if limit == 0

      current_size.to_f / limit.to_f
    end

    def error_message
      @error_message_object ||= Gitlab::NamespaceSizeErrorMessage.new(self)
    end
  end
end
