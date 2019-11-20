# frozen_string_literal: true

require 'spec_helper'

describe ElasticCommitIndexerWorker do
  let!(:project) { create(:project, :repository) }

  subject { described_class.new }

  describe '#perform' do
    before do
      stub_ee_application_setting(elasticsearch_indexing: true)
    end

    it 'runs indexer' do
      expect(Gitlab::Elastic::Indexer).to receive(:run)
        .with(project, to_sha: '0000', wiki: false)

      subject.perform(project.id, nil, '0000')
    end

    it 'returns true if ES disabled' do
      stub_ee_application_setting(elasticsearch_indexing: false)

      expect(Gitlab::Elastic::Indexer).not_to receive(:run)

      expect(subject.perform(1)).to be_truthy
    end

    it 'runs indexer in wiki mode if asked to' do
      expect(Gitlab::Elastic::Indexer).to receive(:run)
        .with(project, to_sha: nil, wiki: true)

      subject.perform(project.id, nil, nil, true)
    end
  end
end
