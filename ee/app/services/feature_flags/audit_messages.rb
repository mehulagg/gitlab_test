# frozen_string_literal: true

module FeatureFlags
  class AuditMessages
    def self.strategy_message(environment_name, strategy_changes)
      return if strategy_changes.nil? || strategy_changes.empty?

      previous_strategies, new_strategies = strategy_changes["strategies"]
      previous_percentage = percentage(previous_strategies)
      new_percentage = percentage(new_strategies)
      template = "Updated rule <strong>%s</strong> rollout from <strong>%s</strong> to <strong>%s</strong>."
      sprintf(template, environment_name, text(previous_percentage), text(new_percentage)) unless previous_percentage == new_percentage
    end

    class << self
      private

      def percentage(strategies)
        strategy = strategies && strategies.first
        strategy && strategy.dig('parameters', 'percentage')
      end

      def text(percentage)
        percentage ? "#{percentage}%" : "unset"
      end
    end
  end
end
