# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['ClusterAgent'] do
  let(:fields) { %i[created_at id name project updated_at tokens] }

  it { expect(described_class.graphql_name).to eq('ClusterAgent') }

  it { expect(described_class).to require_graphql_authorizations(:admin_cluster) }

  it { expect(described_class).to have_graphql_fields(fields) }
end
