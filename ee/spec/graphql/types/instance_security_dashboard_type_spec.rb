# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['InstanceSecurityDashboard'] do
  it { expect(described_class).to have_graphql_fields(%i[vulnerabilities]) }
  it { expect(described_class).to require_graphql_authorizations(:read_instance_security_dashboard) }

  describe 'vulnerabilities' do
    let_it_be(:project) { create(:project) }
    let_it_be(:user) { create(:user) }
    let_it_be(:vulnerability) { create(:vulnerability, project: project) }

    let_it_be(:query) do
      %(
        query {
          instanceSecurityDashboard {
            vulnerabilities {
              nodes {
                title
              }
            }
          }
        }
      )
    end

    before do
      project.add_developer(user)

      user.security_dashboard_projects << project
    end

    subject { GitlabSchema.execute(query, context: { current_user: user }).as_json }

    context 'when first_class_vulnerabilities is disabled' do
      before do
        stub_feature_flags(first_class_vulnerabilities: false)
      end

      it 'is null' do
        vulnerabilities = subject.dig('data', 'instanceSecurityDashboard', 'vulnerabilities')

        expect(vulnerabilities).to be_nil
      end
    end

    context 'when first_class_vulnerabilities is enabled' do
      before do
        stub_feature_flags(first_class_vulnerabilities: true)
        stub_licensed_features(security_dashboard: true)
      end

      it "returns the project's vulnerabilities" do
        vulnerabilities = subject.dig('data', 'instanceSecurityDashboard', 'vulnerabilities', 'nodes')

        expect(vulnerabilities.count).to be(1)
      end
    end
  end
end
