# frozen_string_literal: true

require 'spec_helper'

describe Security::VulnerabilitiesFinder do
  let_it_be(:project) { create(:project) }

  let_it_be(:vulnerability1) do
    create(:vulnerability, severity: :low, report_type: :sast, state: :detected, project: project)
  end

  let_it_be(:vulnerability2) do
    create(:vulnerability, severity: :medium, report_type: :dast, state: :dismissed, project: project)
  end

  let_it_be(:vulnerability3) do
    create(:vulnerability, severity: :high, report_type: :dependency_scanning, state: :confirmed, project: project)
  end

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

  context 'when filtered by report type' do
    let(:filters) { { report_types: %w[sast dast] } }

    it 'only returns vulnerabilities matching the given report types' do
      is_expected.to contain_exactly(vulnerability1, vulnerability2)
    end
  end

  context 'when filtered by severity' do
    let(:filters) { { severities: %w[medium low] } }

    it 'only returns vulnerabilities matching the given severities' do
      is_expected.to contain_exactly(vulnerability1, vulnerability2)
    end
  end

  context 'when filtered by state' do
    let(:filters) { { states: %w[detected confirmed] } }

    it 'only returns vulnerabilities matching the given states' do
      is_expected.to contain_exactly(vulnerability1, vulnerability3)
    end
  end

  context 'when filtered by more than one property' do
    it 'only returns vulnerabilities matching all of the given filters'
  end
end
