# frozen_string_literal: true

FactoryBot.define do
  factory :users_statistic do
    captured_at { FFaker::Time.datetime }
  end
end
