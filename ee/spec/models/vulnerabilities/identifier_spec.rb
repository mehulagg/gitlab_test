# frozen_string_literal: true

require 'spec_helper'

describe Vulnerabilities::Identifier do
  describe 'associations' do
    it { is_expected.to have_many(:occurrence_identifiers).class_name('Vulnerabilities::OccurrenceIdentifier') }
    it { is_expected.to have_many(:occurrences).class_name('Vulnerabilities::Occurrence') }
    it { is_expected.to have_many(:primary_occurrences).class_name('Vulnerabilities::Occurrence') }
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    let!(:identifier) { create(:vulnerabilities_identifier) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:external_type) }
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:fingerprint) }
    # Uniqueness validation doesn't work with binary columns. See TODO in class file
    # it { is_expected.to validate_uniqueness_of(:fingerprint).scoped_to(:project_id) }
  end

  describe '.with_fingerprint' do
    let(:fingerprint) { 'f5724386167705667ae25a1390c0a516020690ba' }

    subject { described_class.with_fingerprint(fingerprint) }

    context 'when identifier has the corresponding fingerprint' do
      let!(:identifier) { create(:vulnerabilities_identifier, fingerprint: fingerprint) }

      it 'selects the identifier' do
        is_expected.to eq([identifier])
      end
    end

    context 'when identifier does not have the corresponding fingerprint' do
      let!(:identifier) { create(:vulnerabilities_identifier) }

      it 'does not select the identifier' do
        is_expected.to be_empty
      end
    end
  end

  describe '.unused' do
    let(:occurrence) { create(:vulnerabilities_occurrence) }
    let!(:used_identifier) do
      create(:vulnerabilities_occurrence_identifier,
             occurrence: occurrence)
    end
    let!(:unused_identifier) { create(:vulnerabilities_identifier) }

    subject { described_class.unused }

    it 'returns only identifier without occurrence' do
      expect(subject.count).to eq 1
      expect(subject.first).to eq unused_identifier
    end
  end
end
