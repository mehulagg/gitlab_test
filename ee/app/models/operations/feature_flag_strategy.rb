# frozen_string_literal: true

module Operations
  class FeatureFlagStrategy < ApplicationRecord
    self.table_name = 'operations_feature_flag_strategies'

    belongs_to :feature_flag_scope

    serialize :parameters, JSON # rubocop:disable Cop/ActiveRecordSerialize

    validate :parameters_validation, :name_validation

    before_create :set_data
    before_update :set_data

    def set_data
      if self.parameters['percentage'].blank?
        self.name = "default"
        self.parameters = {}
      else
        self.name = "gradualRolloutUserId"
        self.parameters = { groupId: "default" }.merge(self.parameters)
      end
    end

    def parameters_validation
      percentage = parameters['percentage']
      group_id = parameters['groupId']

      unless percentage.is_a?(String) && percentage.match(/\A[1-9]?[0-9]\z|\A100\z/)
        errors.add(:parameters, 'percentage must be a string between 0 and 100 inclusive')
      end

      if percentage && group_id.nil?
        errors.add(:parameters, 'groupId parameter is required if percentage parameter is set')
      end

      if percentage && !group_id.nil? && !groupId.is_a?(String)
        errors.add(:parameters, 'groupId parameter must be a string')
      end
    end

    def name_validation
      if parameters['percentage'] && name != 'gradualRolloutUserId'
        errors.add(:name, 'must be gradualRolloutUserId if percentage parameter is set')
      elsif name != 'default'
        errors.add(:name, 'must be default if percentage parameter is not set')
      end
    end
  end
end
