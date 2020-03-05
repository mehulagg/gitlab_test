# frozen_string_literal: true

FactoryBot.define do
  factory :operations_feature_flag, class: 'Operations::FeatureFlag' do
    sequence(:name) { |n| "feature_flag_#{n}" }
    project
    active { true }

    trait :legacy_flag do
      version { 1 }
    end

    trait :new_version_flag do
      version { 2 }
    end
  end
end
