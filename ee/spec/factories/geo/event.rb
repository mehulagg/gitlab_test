# frozen_string_literal: true

FactoryBot.define do
  factory :geo_event, class: 'Geo::Event' do
    replicable_name { 'package_file' }
    event_name { 'created' }
  end
end
