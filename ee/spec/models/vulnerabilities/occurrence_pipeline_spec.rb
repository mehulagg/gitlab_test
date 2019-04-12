# frozen_string_literal: true

require 'spec_helper'

describe Vulnerabilities::OccurrencePipeline do
  describe 'associations' do
    it { is_expected.to belong_to(:pipeline).class_name('Ci::Pipeline') }
    it { is_expected.to belong_to(:occurrence).class_name('Vulnerabilities::Occurrence') }
  end

  describe 'validations' do
    let!(:occurrence_pipeline) { create(:vulnerabilities_occurrence_pipeline) }

    it { is_expected.to validate_presence_of(:occurrence) }
    it { is_expected.to validate_presence_of(:pipeline) }
    it { is_expected.to validate_uniqueness_of(:pipeline_id).scoped_to(:occurrence_id) }
  end

  describe '.outdated_from' do
    let!(:old_pipeline) { create(:ci_empty_pipeline, created_at: 4.days.ago) }
    let!(:new_pipeline) { create(:ci_empty_pipeline) }
    let!(:old_entities) { create_list(:vulnerabilities_occurrence_pipeline, 3, pipeline: old_pipeline) }
    let!(:new_entities) { create_list(:vulnerabilities_occurrence_pipeline, 2, pipeline: new_pipeline) }

    subject { described_class.outdated_from(1.day.ago) }

    it { is_expected.to eq(old_entities) }
  end
end
