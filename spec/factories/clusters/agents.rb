# frozen_string_literal: true

FactoryBot.define do
  factory :cluster_agent, class: 'Clusters::Agent' do
    project { create(:project, :custom_repo, files: ["agents/#{name}/config.yaml"]) }

    sequence(:name) { |n| "agent-#{n}" }
  end
end
