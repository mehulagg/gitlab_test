# frozen_string_literal: true

module FeatureFlags
  class AuditMessages
    def self.strategy_message(environment_name, strategy_changes)
      return if strategy_changes.nil? || strategy_changes.empty?

      previous_parameters, new_parameters = strategy_changes["parameters"]
      previous_percentage = previous_parameters && previous_parameters["percentage"]
      new_percentage = new_parameters["percentage"]
      previous_text = previous_percentage ? "#{previous_percentage}%" : "unset"
      new_text = new_percentage.blank? ? "unset" : "#{new_percentage}%"

      template = "Updated rule <strong>%s</strong> rollout from <strong>%s</strong> to <strong>%s</strong>."

      sprintf(template, environment_name, previous_text, new_text) unless previous_percentage == new_percentage
    end
  end
end
