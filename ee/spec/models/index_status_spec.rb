# frozen_string_literal: true

require 'spec_helper'

describe IndexStatus do
  subject { create(:index_status) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:elasticsearch_index) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:project_id) }
    it { is_expected.to validate_presence_of(:elasticsearch_index_id) }

    it { is_expected.to validate_uniqueness_of(:project_id).scoped_to(:elasticsearch_index_id) }
  end

  describe 'scopes' do
    let_it_be(:project1) { create(:project) }
    let_it_be(:project2) { create(:project) }

    let_it_be(:index1) { create(:elasticsearch_index) }
    let_it_be(:index2) { create(:elasticsearch_index) }

    let_it_be(:status1) { create(:index_status, project: project1, elasticsearch_index: index2) }
    let_it_be(:status2) { create(:index_status, project: project2, elasticsearch_index: index1) }

    describe 'for_project' do
      it 'returns index statuses for the project' do
        expect(described_class.for_project(project1)).to eq([status1])
        expect(described_class.for_project(project2)).to eq([status2])
      end
    end

    describe 'for_index' do
      it 'returns index statuses for the index' do
        expect(described_class.for_index(index1)).to eq([status2])
        expect(described_class.for_index(index2)).to eq([status1])
      end
    end

    describe 'with_indexed_data' do
      let_it_be(:status3) { create(:index_status, last_commit: '1234567', indexed_at: 1.day.ago) }
      let_it_be(:status4) { create(:index_status, last_commit: '1234567') }
      let_it_be(:status5) { create(:index_status, indexed_at: 1.day.ago) }

      it 'returns only index statuses with last_commit and indexed_at set' do
        expect(described_class.with_indexed_data).to eq([status3])
      end
    end
  end
end
