# frozen_string_literal: true

FactoryBot.define do
  factory :elasticsearch_index do
    shards { 14 }
    replicas { 7 }
    aws { false }
    name { 'v12p1' }
    friendly_name { 'V 12.1' }
    version { 'v12p1' }
    urls { ['http://localhost:9200', 'http://localhost:9201'] }

    trait :aws do
      aws { true }
      aws_region { 'us-east-2' }
      aws_access_key { 'foo' }
      aws_secret_access_key { 'bar' }
    end
  end
end
