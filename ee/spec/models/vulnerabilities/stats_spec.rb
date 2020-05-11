# frozen_string_literal: true

require 'spec_helper'

describe Vulnerabilities::Stats do
  describe 'default_scope' do
    let_it_be(:project_1) { create(:project) }
    let_it_be(:vulnerability_1) { create(:vulnerability, :critical, project: project_1) }
    let_it_be(:vulnerability_2) { create(:vulnerability, :critical, project: project_1) }
    let_it_be(:vulnerability_3) { create(:vulnerability, :medium, project: project_1) }
    let_it_be(:vulnerability_4) { create(:vulnerability) }
    let_it_be(:vulnerability_5) { create(:vulnerability) }

    context 'when the relation is not scoped to a project' do
      subject(:stats) { described_class.all }

      it 'returns `vulnerability` records grouped by project_id for all projects' do
        expect(stats.to_a.length).to be(3)
      end
    end

    context 'when the relation is scoped to a project' do
      subject(:stats) { described_class.find_by(project: project_1) }

      it 'returns the stats only for scoping project', :aggregate_failures do
        expect(stats.info).to be(0)
        expect(stats.unknown).to be(0)
        expect(stats.low).to be(0)
        expect(stats.medium).to be(1)
        expect(stats.high).to be(0)
        expect(stats.critical).to be(2)
      end
    end
  end

  describe '.columns' do
    let(:expected_columns) { %w(project_id) }

    subject(:columns) { described_class.columns.map(&:name) }

    it 'only inherits `project_id` column from `vulnerabilities` table' do
      expect(columns).to eql(expected_columns)
    end
  end

  describe 'persistence' do
    subject(:save_stats) { stats.save }

    context 'when the object is a new record' do
      let(:stats) { described_class.new }

      it 'raises `ActiveRecord::ReadOnlyRecord` error' do
        expect { save_stats }.to raise_error(ActiveRecord::ReadOnlyRecord)
      end
    end

    context 'when the object is already persisted' do
      let(:vulnerability) { create(:vulnerability) }
      let(:stats) { described_class.find_by(project: vulnerability.project) }

      it 'raises `ActiveRecord::ReadOnlyRecord` error' do
        expect { save_stats }.to raise_error(ActiveRecord::ReadOnlyRecord)
      end
    end
  end

  describe '#as_json' do
    let!(:vulnerability) { create(:vulnerability, :critical) }
    let(:stats) { vulnerability.project.vulnerability_stats }
    let(:expected_hash) do
      {
        info: 0,
        unknown: 0,
        low: 0,
        medium: 0,
        high: 0,
        critical: 1
      }
    end

    subject { stats.as_json.symbolize_keys }

    it { is_expected.to eql(expected_hash) }
  end
end
