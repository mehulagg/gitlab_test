# frozen_string_literal: true

FactoryBot.define do
  factory :project_access_token do
    project
    personal_access_token
  end
end
