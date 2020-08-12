# frozen_string_literal: true

FactoryBot.define do
  factory :cluster_agent, class: 'Clusters::Agent' do
    project

    sequence(:name) { |n| "agent-#{n}" }

    after :build do |agent|
      project = agent.project

      raise 'Failed to create repository!' unless project.create_repository

      project.repository.create_file(
        project.creator,
        "agents/#{agent.name}/config.yaml",
        {},
        message: 'Required cluster agent config file',
        branch_name: 'main'
      )
    end
  end
end
