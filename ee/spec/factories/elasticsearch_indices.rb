# frozen_string_literal: true

FactoryBot.define do
  factory :elasticsearch_index do
    shards { 14 }
    replicas { 7 }
    aws { false }
    name { generate(:title) }
    friendly_name { generate(:title) }
    version { 'V12p1' }

    # In CI we want to use the URL passed down from the environment
    urls { [ENV['ELASTIC_URL'] || 'http://localhost:9200'] }

    trait :aws do
      aws { true }
      aws_region { 'us-east-2' }
      aws_access_key { 'foo' }
      aws_secret_access_key { 'bar' }
    end
  end
end
