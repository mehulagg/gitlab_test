# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::FindingPipeline do
  describe 'associations' do
    it { is_expected.to belong_to(:pipeline).class_name('Ci::Pipeline') }
    it { is_expected.to belong_to(:occurrence).class_name('Vulnerabilities::Occurrence') }
  end

  describe 'validations' do
    let!(:finding_pipeline) { create(:vulnerabilities_finding_pipeline) }

    it { is_expected.to validate_presence_of(:occurrence) }
    it { is_expected.to validate_presence_of(:pipeline) }
    it { is_expected.to validate_uniqueness_of(:pipeline_id).scoped_to(:occurrence_id) }
  end
end
