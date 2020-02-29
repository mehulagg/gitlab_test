# frozen_string_literal: true

require 'spec_helper'

describe EE::VulnerabilitiesHelper do
  before do
    allow(helper).to receive(:can?).and_return(true)
    allow(helper).to receive(:current_user).and_return(user)
  end

  let(:user) { build(:user) }

  describe '#vulnerability_data' do
    let(:vulnerability) { create(:vulnerability, :with_findings) }

    def verify_vulnerability_properties(data, vulnerability)
      expect(data[:id]).to eq vulnerability.id
      expect(data[:state]).to eq vulnerability.state
      expect(data[:created_at]).to eq vulnerability.created_at
      expect(data[:report_type]).to eq vulnerability.report_type
      expect(data[:project_fingerprint]).to eq vulnerability.finding.project_fingerprint
      expect(data[:create_issue_url]).to be_truthy
    end

    it 'returns the expected data when there is no pipeline' do
      data = helper.vulnerability_data(vulnerability, nil)

      verify_vulnerability_properties(data, vulnerability)
      expect(data[:pipeline]).to be_nil
    end

    it 'returns the expected data when there is a pipeline' do
      pipeline = create(:ci_pipeline)
      data = helper.vulnerability_data(vulnerability, pipeline)

      verify_vulnerability_properties(data, vulnerability)
      expect(data[:pipeline][:id]).to eq pipeline.id
      expect(data[:pipeline][:created_at]).to eq pipeline.created_at
      expect(data[:pipeline][:url]).to eq pipeline_path(pipeline)
    end
  end
end
