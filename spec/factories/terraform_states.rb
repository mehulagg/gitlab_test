# frozen_string_literal: true

FactoryBot.define do
  factory :terraform_state do
    name {'example'}
    value {'some terraform state value'}
    lock_info {'some terraform state lock info'}
    project_id { nil }
  end
end
