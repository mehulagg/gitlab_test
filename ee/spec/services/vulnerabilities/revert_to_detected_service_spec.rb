# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::RevertToDetectedService do
  include AccessMatchersGeneric

  before do
    stub_licensed_features(security_dashboard: true)
  end

  let_it_be(:user) { create(:user) }
  let(:project) { create(:project) } # cannot use let_it_be here: caching causes problems with permission-related tests
  let(:vulnerability) { create(:vulnerability, :with_findings, project: project) }
  let(:service) { described_class.new(user, vulnerability) }

  subject(:revert_vulnerability_to_detected) { service.execute }

  shared_examples 'reverts vulnerability' do
    it 'reverts a vulnerability and its associated findings to detected state' do
      Timecop.freeze do
        revert_vulnerability_to_detected

        expect(vulnerability.reload).to(
          have_attributes(state: 'detected', dismissed_by: nil, dismissed_at: nil, resolved_by: nil, resolved_at: nil, confirmed_by: nil, confirmed_at: nil))
        expect(vulnerability.findings).to all not_have_vulnerability_dismissal_feedback
      end
    end

    it 'creates note' do
      expect(SystemNoteService).to receive(:change_vulnerability_state).with(vulnerability, user)

      revert_vulnerability_to_detected
    end

    it_behaves_like 'calls vulnerability statistics utility services in order'
  end

  context 'with an authorized user with proper permissions' do
    before do
      project.add_developer(user)
    end

    context 'when vulnerability is dismissed' do
      let(:vulnerability) { create(:vulnerability, :dismissed, :with_findings, project: project) }

      include_examples 'reverts vulnerability'
    end

    context 'when vulnerability is confirmed' do
      let(:vulnerability) { create(:vulnerability, :confirmed, :with_findings, project: project) }

      include_examples 'reverts vulnerability'
    end

    context 'when vulnerability is resolved' do
      let(:vulnerability) { create(:vulnerability, :resolved, :with_findings, project: project) }

      include_examples 'reverts vulnerability'
    end

    context 'when there is an error' do
      let(:broken_finding) { vulnerability.findings.first }

      let!(:dismissal_feedback) do
        create(:vulnerability_feedback, :dismissal, project: broken_finding.project, project_fingerprint: broken_finding.project_fingerprint)
      end

      before do
        allow(service).to receive(:destroy_feedback_for).and_return(false)
      end

      it 'responds with error' do
        expect(revert_vulnerability_to_detected.errors.messages).to eq(
          base: ["failed to revert associated finding(id=#{broken_finding.id}) to detected"])
      end
    end

    context 'when security dashboard feature is disabled' do
      before do
        stub_licensed_features(security_dashboard: false)
      end

      it 'raises an "access denied" error' do
        expect { revert_vulnerability_to_detected }.to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end
  end

  describe 'permissions' do
    it { expect { revert_vulnerability_to_detected }.to be_allowed_for(:admin) }
    it { expect { revert_vulnerability_to_detected }.to be_allowed_for(:owner).of(project) }
    it { expect { revert_vulnerability_to_detected }.to be_allowed_for(:maintainer).of(project) }
    it { expect { revert_vulnerability_to_detected }.to be_allowed_for(:developer).of(project) }

    it { expect { revert_vulnerability_to_detected }.to be_denied_for(:auditor) }
    it { expect { revert_vulnerability_to_detected }.to be_denied_for(:reporter).of(project) }
    it { expect { revert_vulnerability_to_detected }.to be_denied_for(:guest).of(project) }
    it { expect { revert_vulnerability_to_detected }.to be_denied_for(:anonymous) }
  end
end
