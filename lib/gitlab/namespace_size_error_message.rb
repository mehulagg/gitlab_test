# frozen_string_literal: true

module Gitlab
  class NamespaceSizeErrorMessage
    include ActiveSupport::NumberHelper

    delegate :current_size, :limit, :enabled?, :usage_ratio, :namespace, to: :@checker

    # @param checher [NamespaceSizeChecker]
    def initialize(checker)
      @checker = checker
    end

    def info_message
      return unless should_show_message?

      s_("If you reach 100% capacity, you will not be able to: push to your repository, create pipelines, create issues or add comments. You can either reduce your usage or buy additional storage.")
    end

    def statistics_message
      return unless should_show_message?

      s_("You reached %{usage_in_percent} of %{namespace_name}'s capacity (%{used_storage} of %{storage_limit})" % { usage_in_percent: number_to_percentage(usage_ratio * 100, precision: 0), namespace_name: namespace.name, used_storage: formatted(current_size), storage_limit: formatted(limit) })
    end

    def alert_level
      case usage_ratio
      when 0..0.49
        nil
      when 0.50..0.75
        :info
      when 0.75..0.95
        :warning
      else
        :danger
      end
    end

    private

    def should_show_message?
      return false unless enabled?
      return false if alert_level.nil?

      true
    end

    def formatted(number)
      number_to_human_size(number, delimiter: ',', precision: 2)
    end
  end
end
