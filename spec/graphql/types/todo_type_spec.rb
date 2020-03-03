# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['Todo'] do
  it 'has the correct fields' do
    expected_fields = [:id, :project, :group, :author, :action, :target_type, :body, :state, :created_at]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end

  it { expect(described_class).to require_graphql_authorizations(:read_todo) }
end
