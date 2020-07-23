# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['BoardUserPreference'] do
  let(:fields) { :hide_labels }

  it { expect(described_class.graphql_name).to eq('BoardUserPreference') }

  it { expect(described_class).to have_graphql_fields(fields) }
end
