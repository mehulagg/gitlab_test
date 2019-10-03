# frozen_string_literal: true

FactoryBot.define do
  factory :group_export, class: GroupExport do
    association :group, factory: :group

    status { 0 }

    trait :created do
      status { 0 }
    end

    trait :started do
      status { 3 }
    end

    trait :finished do
      status { 9 }
    end

    trait :failed do
      status { -1 }
    end
  end
end
