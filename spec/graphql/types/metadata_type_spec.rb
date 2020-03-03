# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['Metadata'] do
  it { expect(described_class.graphql_name).to eq('Metadata') }
  it { expect(described_class).to require_graphql_authorizations(:read_instance_metadata) }
end
