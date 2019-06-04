# frozen_string_literal: true

module Operations
  class FeatureFlagStrategy < ApplicationRecord
    self.table_name = 'operations_feature_flag_strategies'

    belongs_to :feature_flag_scope

    validates :name, inclusion: { in: %w(default gradualRolloutUserId) }
    validate :parameters_validation

    before_create do
      self.parameters = {} if self.parameters.nil?
    end

    private

    def parameters_validation
      gradual_rollout_user_id_parameters_validation if name == 'gradualRolloutUserId'
      default_parameters_validation if name == 'default'
    end

    def gradual_rollout_user_id_parameters_validation
      percentage = parameters && parameters['percentage']
      group_id = parameters && parameters['groupId']

      unless percentage.is_a?(String) && percentage.match(/\A[1-9]?[0-9]\z|\A100\z/)
        errors.add(:parameters, 'percentage must be a string between 0 and 100 inclusive')
      end

      unless group_id.is_a?(String)
        errors.add(:parameters, 'groupId parameter must be a string')
      end
    end

    def default_parameters_validation
      unless parameters == {} || parameters.nil?
        errors.add(:parameters, 'parameters must be empty for default strategy')
      end
    end
  end
end
