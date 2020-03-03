# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['EpicIssueLink'] do
  it { expect(described_class.graphql_name).to eq('EpicIssueLink') }

  it { expect(described_class).to require_graphql_authorizations(:read_epic_issue) }

  it 'has specific fields' do
    %i[id epic issue relative_position].each do |field_name|
      expect(described_class).to have_graphql_field(field_name)
    end
  end
end
