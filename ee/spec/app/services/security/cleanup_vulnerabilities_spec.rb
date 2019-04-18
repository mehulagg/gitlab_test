# frozen_string_literal: true

require 'spec_helper'

describe Security::CleanupVulnerabilities do
  describe '#execute' do
    let!(:old_pipeline) { create(:ci_empty_pipeline, created_at: 400.days.ago) }
    let!(:new_pipeline) { create(:ci_empty_pipeline) }

    let!(:occurrence1) { create(:vulnerabilities_occurrence, scanner: old_scanner, primary_identifier: old_identifier) }
    let!(:occurrence11) { create(:vulnerabilities_occurrence, scanner: old_scanner2, primary_identifier: old_identifier2) }
    let!(:occurrence2) { create_list(:vulnerabilities_occurrence, 2, scanner: new_scanner, primary_identifier: new_identifier) }

    let!(:old_scanner) { create(:vulnerabilities_scanner) }
    let!(:old_scanner2) { create(:vulnerabilities_scanner) }
    let!(:new_scanner) { create(:vulnerabilities_scanner) }

    let!(:old_identifier) { create(:vulnerabilities_identifier) }
    let!(:old_identifier2) { create(:vulnerabilities_identifier) }
    let!(:new_identifier) { create(:vulnerabilities_identifier) }

    let!(:vul_oc_id1) {create(:vulnerabilities_occurrence_identifier, occurrence: occurrence1, identifier: old_identifier)}
    let!(:vul_oc_id2) {create(:vulnerabilities_occurrence_identifier, occurrence: occurrence11, identifier: old_identifier2)}
    let!(:vul_oc_id4) {create(:vulnerabilities_occurrence_identifier, occurrence: occurrence2[0], identifier: new_identifier)}
    let!(:vul_oc_id5) {create(:vulnerabilities_occurrence_identifier, occurrence: occurrence2[1], identifier: new_identifier)}

    let!(:vul_oc_pp1) {create(:vulnerabilities_occurrence_pipeline, occurrence: occurrence1, pipeline: old_pipeline)}
    let!(:vul_oc_pp2) {create(:vulnerabilities_occurrence_pipeline, occurrence: occurrence11, pipeline: old_pipeline)}
    let!(:vul_oc_pp22) {create(:vulnerabilities_occurrence_pipeline, occurrence: occurrence11, pipeline: new_pipeline)}
    let!(:vul_oc_pp4) {create(:vulnerabilities_occurrence_pipeline, occurrence: occurrence2[0], pipeline: new_pipeline)}
    let!(:vul_oc_pp5) {create(:vulnerabilities_occurrence_pipeline, occurrence: occurrence2[1], pipeline: new_pipeline)}

    before do
      described_class.new.execute
    end

    it 'delete all old info' do
      expect(Ci::Pipeline.count).to eq 2
      expect(Vulnerabilities::OccurrencePipeline.count).to eq 3
      expect(Vulnerabilities::Occurrence.count).to eq 3
      expect(Vulnerabilities::Identifier.count).to eq 2
      expect(Vulnerabilities::Scanner.count).to eq 2
      expect(Vulnerabilities::OccurrenceIdentifier.count).to eq 3
    end
  end
end
