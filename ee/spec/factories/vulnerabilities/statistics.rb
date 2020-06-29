# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerability_statistic, class: 'Vulnerabilities::Statistic' do
    project
    letter_grade { %w(a b c d f).sample }
    date { Date.today }

    trait :current do
      date { nil }
    end
  end
end
