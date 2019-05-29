# frozen_string_literal: true

FactoryBot.define do
  factory :operations_feature_flag_strategy, class: Operations::FeatureFlagStrategy do
    association :feature_flag_scope, factory: :operations_feature_flag_scope
    name "gradualRolloutUserId"
    parameters { { groupId: "mygroup", percentage: "50" } }
  end
end
