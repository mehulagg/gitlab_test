# frozen_string_literal: true

FactoryBot.define do
  factory :index_status do
    project
    elasticsearch_index
  end
end
