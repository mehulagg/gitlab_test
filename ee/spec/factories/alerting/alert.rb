# frozen_string_literal: true

FactoryBot.define do
  factory :alerting_alert, class: Gitlab::Alerting::Alert do
    project
    payload { Gitlab::Alerting::AlertPayloadParser.call({}) }

    transient do
      metric_id nil

      after(:build) do |alert, evaluator|
        unless alert.payload.to_h.with_indifferent_access.key?('starts_at')
          alert.payload.starts_at = Time.now.rfc3339
        end

        if metric_id = evaluator.metric_id
          alert.payload.metric_id = metric_id
        end
      end
    end

    skip_create
  end
end
