# frozen_string_literal: true

FactoryBot.define do
  factory :value_stream_analytics_project_stage, class: 'Analytics::ValueStreamAnalytics::ProjectStage' do
    project
    sequence(:name) { |n| "Stage ##{n}" }
    hidden { false }
    issue_stage

    trait :issue_stage do
      start_event_identifier { Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueCreated.identifier }
      end_event_identifier { Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueStageEnd.identifier }
    end
  end
end
