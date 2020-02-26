# frozen_string_literal: true

FactoryBot.define do
  factory :users_statistic do
    as_at { FFaker::Time.datetime }
  end
end
