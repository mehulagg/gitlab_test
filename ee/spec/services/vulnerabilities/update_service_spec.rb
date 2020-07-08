# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::UpdateService do
  before do
    stub_licensed_features(security_dashboard: true)
  end

  let_it_be(:user) { create(:user) }
  let!(:project) { create(:project) } # cannot use let_it_be here: caching causes problems with permission-related tests
  let!(:updated_finding) { create(:vulnerabilities_occurrence, project: project, name: 'New title', severity: :critical, confidence: :confirmed, vulnerability: vulnerability) }

  let!(:vulnerability) { create(:vulnerability, project: project, severity: :low, severity_overridden: severity_overridden, confidence: :ignore, confidence_overridden: confidence_overridden) }
  let(:severity_overridden) { false }
  let(:confidence_overridden) { false }

  subject { described_class.new(project, user, finding: updated_finding).execute }

  context 'with an authorized user with proper permissions' do
    before do
      project.add_developer(user)
    end

    context 'when neither severity nor confidence are overridden' do
      it 'updates the vulnerability from updated finding (title, severity and confidence only)', :aggregate_failures do
        expect { subject }.not_to change { project.vulnerabilities.count }
        expect(vulnerability.previous_changes.keys).to contain_exactly(*%w[updated_at title title_html severity confidence])
        expect(vulnerability).to(
          have_attributes(
            title: 'New title',
            severity: 'critical',
            confidence: 'confirmed'
          ))
      end
    end

    context 'when severity is overridden' do
      let(:severity_overridden) { true }

      it 'updates the vulnerability from updated finding (title and confidence only)' do
        expect { subject }.not_to change { project.vulnerabilities.count }
        expect(vulnerability.previous_changes.keys).to contain_exactly(*%w[updated_at title title_html confidence])
        expect(vulnerability).to(
          have_attributes(
            title: 'New title',
            confidence: 'confirmed'
          ))
      end
    end

    context 'when confidence is overridden' do
      let(:confidence_overridden) { true }

      it 'updates the vulnerability from updated finding (title and severity only)' do
        expect { subject }.not_to change { project.vulnerabilities.count }
        expect(vulnerability.previous_changes.keys).to contain_exactly(*%w[updated_at title title_html severity])
        expect(vulnerability).to(
          have_attributes(
            title: 'New title',
            severity: 'critical'
          ))
      end
    end

    context 'when security dashboard feature is disabled' do
      before do
        stub_licensed_features(security_dashboard: false)
      end

      it 'raises an "access denied" error' do
        expect { subject }.to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end
  end

  context 'when user does not have rights to update a vulnerability' do
    before do
      project.add_reporter(user)
    end

    it 'raises an "access denied" error' do
      expect { subject }.to raise_error(Gitlab::Access::AccessDeniedError)
    end
  end
end
