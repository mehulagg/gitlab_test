# frozen_string_literal: true

require 'spec_helper'

describe VulnerabilitiesSummaryPolicy do
  describe 'read_vulnerability' do
    let(:project) { create(:project) }
    let(:user) { create(:user) }
    let(:vulnerabilities_summary) { VulnerabilitiesSummary.new(vulnerable: project) }

    subject { described_class.new(user, vulnerabilities_summary) }

    context 'when the security_dashboard feature is enabled' do
      before do
        stub_licensed_features(security_dashboard: true)
      end

      context "when the current user has developer access to the vulnerability's project" do
        before do
          project.add_developer(user)
        end

        it do
          is_expected.to be_allowed(:read_vulnerability)
        end
      end

      context "when the current user does not have developer access to the vulnerability's project" do
        it do
          is_expected.to be_disallowed(:read_vulnerability)
        end
      end
    end

    context 'when the security_dashboard feature is disabled' do
      before do
        stub_licensed_features(security_dashboard: false)

        project.add_developer(user)
      end

      it do
        is_expected.to be_disallowed(:read_vulnerability)
      end
    end
  end
end
