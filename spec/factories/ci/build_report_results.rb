# frozen_string_literal: true

FactoryBot.define do
  factory :ci_build_report_results, class: 'Ci::BuildReportResults' do
    build factory: :ci_build

    trait :junit_success do
      file_type { "junit" }
      report_param { "success" }
      value { 10 }
    end
  end
end
