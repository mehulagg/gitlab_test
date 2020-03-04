# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['Query'] do
  it do
    is_expected.to have_graphql_fields(:design_management, :instance_security_dashboard).at_least
  end

  describe 'instance_security_dashboard' do
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

    context 'when instance_security_dashboard is enabled' do
      before do
        stub_feature_flags(instance_security_dashboard: true)
        stub_licensed_features(security_dashboard: true)
      end

      it 'responds with the requested instance security dashboard fields' do
        vulnerabilities = subject.dig('data', 'instanceSecurityDashboard', 'vulnerabilities', 'nodes')

        expect(vulnerabilities.count).to be(1)
      end
    end

    context 'when instance_security_dashboard is disabled' do
      before do
        stub_feature_flags(instance_security_dashboard: false)
      end

      it 'responds with null' do
        vulnerabilities = subject.dig('data', 'instanceSecurityDashboard', 'vulnerabilities')

        expect(vulnerabilities).to be_nil
      end
    end
  end
end
