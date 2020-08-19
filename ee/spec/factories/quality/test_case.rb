# frozen_string_literal: true

FactoryBot.define do
  factory :quality_test_case, class: 'Quality::TestCase' do
    project
    title { generate(:title) }
    title_html { "<h2>#{title}</h2>" }
    description { FFaker::Lorem.sentence }
    description_html { "<p>#{description}</p>" }
  end
end
