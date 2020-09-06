# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastScannerProfilesFinder do
  let!(:current_user) { create(:user) }
  let!(:dast_scanner_profile1) { create(:dast_scanner_profile) }
  let!(:project1) { dast_scanner_profile1.project }
  let!(:dast_scanner_profile2) { create(:dast_scanner_profile) }
  let!(:project2) { dast_scanner_profile2.project }

  let(:params) { {} }

  subject do
    described_class.new(params).execute
  end

  describe '#execute' do
    it 'returns all dast_scanner_profiles' do
      expect(subject).to contain_exactly(dast_scanner_profile1, dast_scanner_profile2)
    end

    context 'filtering by id' do
      let(:params) { { id: dast_scanner_profile1.id } }

      it 'returns a single dast_scanner_profile' do
        expect(subject).to contain_exactly(dast_scanner_profile1)
      end
    end

    context 'filter by project' do
      let(:params) { { project_id: dast_scanner_profile2.project.id } }

      it 'returns a single dast_scanner_profile' do
        expect(subject).to contain_exactly(dast_scanner_profile2)
      end
    end

    context 'when DastScannerProfile id is for a different project' do
      let(:params) { { id: dast_scanner_profile1.id, project_id: dast_scanner_profile2.project.id } }

      it 'returns an empty relation' do
        expect(subject).to be_empty
      end
    end

    context 'when the dast_scanner_profile1 does not exist' do
      let(:params) { { id: 0 } }

      it 'returns an empty relation' do
        expect(subject).to be_empty
      end
    end
  end
end
