# frozen_string_literal: true

require 'spec_helper'

describe Security::CleanupVulnerabilities do
  describe '#execute' do
    let!(:old_pipeline) { create(:ci_empty_pipeline, created_at: 400.days.ago) }
    let!(:new_pipeline) { create(:ci_empty_pipeline) }

    let!(:occurrence1) { create_list(:vulnerabilities_occurrence, 4, scanner: old_scanner) }
    let!(:occurrence2) { create_list(:vulnerabilities_occurrence, 2, scanner: new_scanner) }

    let!(:old_scanner) { create(:vulnerabilities_scanner) }
    let!(:new_scanner) { create(:vulnerabilities_scanner) }
    #identifiers
    let!(:old_identifier) { create(:vulnerabilities_identifier) }
    let!(:new_identifier) { create(:vulnerabilities_identifier) }

    let!(:vul_oc_id1) {create(:vulnerabilities_occurrence_identifier, occurrence: occurrence1[0], identifier: old_identifier)}
    let!(:vul_oc_id2) {create(:vulnerabilities_occurrence_identifier, occurrence: occurrence1[1], identifier: old_identifier)}
    let!(:vul_oc_id3) {create(:vulnerabilities_occurrence_identifier, occurrence: occurrence1[2], identifier: old_identifier)}
    let!(:vul_oc_id33) {create(:vulnerabilities_occurrence_identifier, occurrence: occurrence1[3], identifier: old_identifier)}
    let!(:vul_oc_id4) {create(:vulnerabilities_occurrence_identifier, occurrence: occurrence2[0], identifier: new_identifier)}
    let!(:vul_oc_id5) {create(:vulnerabilities_occurrence_identifier, occurrence: occurrence2[1], identifier: new_identifier)}

    let!(:vul_oc_pp1) {create(:vulnerabilities_occurrence_pipeline, occurrence: occurrence1[0], pipeline: old_pipeline)}
    let!(:vul_oc_pp2) {create(:vulnerabilities_occurrence_pipeline, occurrence: occurrence1[1], pipeline: old_pipeline)}
    let!(:vul_oc_pp22) {create(:vulnerabilities_occurrence_pipeline, occurrence: occurrence1[1], pipeline: new_pipeline)}
    let!(:vul_oc_pp33) {create(:vulnerabilities_occurrence_pipeline, occurrence: occurrence1[2], pipeline: old_pipeline)}
    let!(:vul_oc_pp3) {create(:vulnerabilities_occurrence_pipeline, occurrence: occurrence1[3], pipeline: old_pipeline)}
    let!(:vul_oc_pp4) {create(:vulnerabilities_occurrence_pipeline, occurrence: occurrence2[0], pipeline: new_pipeline)}
    let!(:vul_oc_pp5) {create(:vulnerabilities_occurrence_pipeline, occurrence: occurrence2[1], pipeline: new_pipeline)}

    subject { described_class.new.execute }

    it 'delete all old info' do
      expect(Ci::Pipeline.count).to eq 2
      expect(Vulnerabilities::Occurrence.count).to eq 6
      expect(Vulnerabilities::OccurrencePipeline.count).to eq 7
      expect(Vulnerabilities::Identifier.count).to eq 2
      expect(Vulnerabilities::Scanner.count).to eq 2

      subject

      expect(Ci::Pipeline.count).to eq 2
      expect(Vulnerabilities::Occurrence.count).to eq 3
      expect(Vulnerabilities::OccurrencePipeline.count).to eq 3
      expect(Vulnerabilities::Identifier.count).to eq 1
      expect(Vulnerabilities::Scanner.count).to eq 1
    end
  end
end