# frozen_string_literal: true

FactoryBot.define do
  factory :gitlab_subscription do
    namespace
    association :hosted_plan, factory: :gold_plan
    seats { 10 }
    start_date { Date.today }
    end_date { Date.today.advance(years: 1) }
    trial { false }

    trait :expired do
      start_date { Date.today.advance(years: -1, months: -1) }
      end_date { Date.today.advance(months: -1) }
    end

    trait :active_trial do
      trial { true }
      trial_ends_on { Date.today.advance(months: 1) }
    end

    trait :expired_trial do
      trial { true }
      trial_ends_on { Date.today.advance(days: -1) }
    end

    trait :default do
      association :hosted_plan, factory: :default_plan
    end

    trait :free do
      hosted_plan_id { nil }
    end

    trait :bronze do
      association :hosted_plan, factory: :bronze_plan
    end

    trait :silver do
      association :hosted_plan, factory: :silver_plan
    end

    trait :gold do
      association :hosted_plan, factory: :gold_plan
    end

    # for testing elasticsearch_indexed_namespace and elastic_namespace_rollout_worker which
    # eventually will not be required once all paid groups are indexed
    trait :without_index_namespace_callback do
      after(:build) do |gitlab_subcription|
        GitlabSubscription.skip_callback(:commit, :after, :index_namespace)
      end

      after(:create) do
        GitlabSubscription.set_callback(:commit, :after, :index_namespace)
      end
    end
  end
end
