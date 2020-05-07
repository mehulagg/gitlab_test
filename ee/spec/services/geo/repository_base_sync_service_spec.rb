# frozen_string_literal: true

require 'spec_helper'

describe Geo::RepositoryBaseSyncService do
  let(:project) { build('project') }

  subject { described_class.new(project) }

  describe '#lease_key' do
    it 'returns a key in the correct pattern' do
      allow(described_class).to receive(:type) { :wiki }
      allow(project).to receive(:id) { 999 }

      expect(subject.lease_key).to eq('geo_sync_service:wiki:999')
    end
  end

  describe '#execute' do
    let(:perform) { subject.execute }

    before do
      allow(subject).to receive(:sync_repository).and_return(true)
    end

    it_behaves_like 'logs trigger info', 'rescheduled'
  end
end
