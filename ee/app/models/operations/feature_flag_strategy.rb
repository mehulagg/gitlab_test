# frozen_string_literal: true

module Operations
  class FeatureFlagStrategy < ApplicationRecord
    self.table_name = 'operations_feature_flag_strategies'

    belongs_to :feature_flag_scope

    serialize :parameters, JSON # rubocop:disable Cop/ActiveRecordSerialize

    before_create do
      self.name = "gradualRolloutUserId"
      self.parameters = { groupId: "default" }.merge(self.parameters)
    end
  end
end
