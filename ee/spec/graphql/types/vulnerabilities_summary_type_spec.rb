# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['VulnerabilitySummary'] do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  let(:fields) do
    ::Vulnerabilities::Occurrence::SEVERITY_LEVELS.keys + %i[user_permissions]
  end

  let(:query) do
    %(
      query {
        project(fullPath:"#{project.full_path}") {
          vulnerabilitiesSummary {
            high
          }
        }
      }
    )
  end

  before do
    stub_licensed_features(security_dashboard: true)

    project.add_developer(user)
  end

  subject { GitlabSchema.execute(query, context: { current_user: user }).as_json }

  it { expect(described_class.graphql_name).to eq('VulnerabilitySummary') }
  it { expect(described_class).to have_graphql_fields(fields) }

  it 'defaults all fields to 0 if the field is null' do
    high_count = subject.dig('data', 'project', 'vulnerabilitiesSummary', 'high')

    expect(high_count).to be_zero
  end
end
