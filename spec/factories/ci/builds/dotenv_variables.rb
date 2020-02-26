# frozen_string_literal: true

FactoryBot.define do
  factory :ci_build_dotenv_variable, class: 'Ci::Builds::DotenvVariable' do
    sequence(:key) { |n| "VARIABLE_#{n}" }
    value { 'VARIABLE_VALUE' }

    build factory: :ci_build
  end
end
