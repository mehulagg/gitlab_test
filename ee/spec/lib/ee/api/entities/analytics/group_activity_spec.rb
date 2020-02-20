# frozen_string_literal: true

require 'spec_helper'

describe EE::API::Entities::Analytics::GroupActivity do
  let(:count) { 10 }
  let(:data) { { issues_count: count, merge_requests_count: count } }

  subject(:entity_representation) { described_class.new(data).as_json }

  it 'exposes analytics data' do
    expect(entity_representation).to include(
      {
        issues_count: count,
        merge_requests_count: count
      }
    )
  end
end
