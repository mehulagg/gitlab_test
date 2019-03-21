# frozen_string_literal: true

FactoryBot.define do
  factory :ci_upstream_bridge, class: ::Ci::Bridges::UpstreamBridge do
    name ' bridge'
    stage 'test'
    stage_idx 0
    ref 'master'
    tag false
    created_at 'Di 29. Okt 09:50:00 CET 2013'
    status :success

    pipeline factory: :ci_pipeline

    transient { upstream nil }

    after(:build) do |bridge, evaluator|
      bridge.project ||= bridge.pipeline.project

      if evaluator.upstream.present?
        bridge.options = bridge.options.to_h.merge(
          triggered_by: { project: evaluator.upstream.full_path }
        )
      end
    end

    trait :invalid_upstream do
      after(:build) do |bridge, _|
        bridge.options = bridge.options.to_h.merge(
          triggered_by: { project: 'this_project/does_not_exist' }
        )
      end
    end
  end
end
