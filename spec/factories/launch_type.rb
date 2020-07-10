# frozen_string_literal: true

FactoryBot.define do
  factory :launch_type, class: 'LaunchType' do
    project
    deploy_target_type { 'eks' }
  end
end
