# frozen_string_literal: true

module Operations
  class FeatureFlagStrategy < ApplicationRecord
    self.table_name = 'operations_feature_flag_strategies'

    belongs_to :feature_flag_scope

    serialize :parameters, JSON # rubocop:disable Cop/ActiveRecordSerialize

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
  end
end
