# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['Dependency'] do
  let(:fields) { %i[name version packager location licenses vulnerabilities] }

  it { expect(described_class).to have_graphql_fields(fields) }

  it { expect(described_class.graphql_name).to eq('Dependency') }

  it { expect(described_class).to require_graphql_authorizations(:read_dependencies) }
end
