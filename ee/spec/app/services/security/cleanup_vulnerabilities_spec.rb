# frozen_string_literal: true

require 'spec_helper'

describe Security::CleanupVulnerabilities do
  describe '#execute' do
    let!(:old_pipeline) { create(:ci_empty_pipeline, created_at: 400.days.ago) }
    let!(:new_pipeline) { create(:ci_empty_pipeline) }

    let!(:old_occurrence) { create(:vulnerabilities_occurrence, scanner: old_scanner, primary_identifier: old_identifier) }
    let!(:new_occurrence1) { create(:vulnerabilities_occurrence, scanner: new_scanner, primary_identifier: new_identifier) }
    let!(:new_occurrence2) { create(:vulnerabilities_occurrence, scanner: new_scanner, primary_identifier: new_identifier2) }

    let!(:old_scanner) { create(:vulnerabilities_scanner) }
    let!(:new_scanner) { create(:vulnerabilities_scanner) }

    let!(:old_identifier) { create(:vulnerabilities_identifier) }
    let!(:new_identifier) { create(:vulnerabilities_identifier) }
    let!(:new_identifier2) { create(:vulnerabilities_identifier) }

    let!(:old_oc_id1) {create(:vulnerabilities_occurrence_identifier, occurrence: old_occurrence, identifier: old_identifier)}
    let!(:new_oc_id1) {create(:vulnerabilities_occurrence_identifier, occurrence: new_occurrence1, identifier: new_identifier)}
    let!(:new_oc_id2) {create(:vulnerabilities_occurrence_identifier, occurrence: new_occurrence2, identifier: new_identifier)}

    let!(:old_oc_pp1) {create(:vulnerabilities_occurrence_pipeline, occurrence: old_occurrence, pipeline: old_pipeline)}
    let!(:old_oc_pp2) {create(:vulnerabilities_occurrence_pipeline, occurrence: new_occurrence1, pipeline: old_pipeline)}
    let!(:new_oc_pp1) {create(:vulnerabilities_occurrence_pipeline, occurrence: new_occurrence1, pipeline: new_pipeline)}
    let!(:new_oc_pp2) {create(:vulnerabilities_occurrence_pipeline, occurrence: new_occurrence2, pipeline: new_pipeline)}

    before do
      described_class.new.execute
    end

    it 'delete all old info' do
      expect(Ci::Pipeline.count).to eq 2
      expect(Vulnerabilities::OccurrencePipeline.count).to eq 2
      expect(Vulnerabilities::Occurrence.count).to eq 2
      expect(Vulnerabilities::Identifier.count).to eq 2
      expect(Vulnerabilities::Scanner.count).to eq 1
      expect(Vulnerabilities::OccurrenceIdentifier.count).to eq 2
    end
  end
end
