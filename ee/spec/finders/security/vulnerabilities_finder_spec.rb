# frozen_string_literal: true

require 'spec_helper'

describe Security::VulnerabilitiesFinder do
  let_it_be(:project) { create(:project) }
  let_it_be(:low_vulnerability) { create(:vulnerability, severity: :low, project: project) }
  let_it_be(:medium_vulnerability) { create(:vulnerability, severity: :medium, project: project) }
  let_it_be(:high_vulnerability) { create(:vulnerability, severity: :high, project: project) }

  let(:filters) { {} }

  subject { described_class.new(project, filters).execute }

  it 'returns vulnerabilities of a project' do
    expect(subject).to match_array(project.vulnerabilities)
  end

  context 'when not given a second argument' do
    subject { described_class.new(project).execute }

    it 'does not filter the vulnerability list' do
      expect(subject).to match_array(project.vulnerabilities)
    end
  end

  context 'when filtered by severity' do
    let(:filters) { { severities: %w[medium low] } }

    it 'only returns vulnerabilities matching the given severities' do
      expect(subject).to contain_exactly(low_vulnerability, medium_vulnerability)
    end
  end

  context 'when filtered by report type' do
    it 'only returns vulnerabilities matching the given report types'
  end

  context 'when filtered by severity and report type' do
    it 'only returns vulnerabilities matching the given severities AND report types'
  end
end
