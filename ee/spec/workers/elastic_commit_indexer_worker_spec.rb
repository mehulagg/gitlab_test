require 'spec_helper'

describe ElasticCommitIndexerWorker do
  let!(:project) { create(:project, :repository) }

  subject { described_class.new }

  describe '#perform' do
    before do
      stub_ee_application_setting(elasticsearch_indexing: true)
    end

    it 'runs indexer' do
      expect_any_instance_of(Gitlab::Elastic::Indexer).to receive(:run)

      subject.perform(project.id, '0000', '0000')
    end

    it 'returns true if ES disabled' do
      stub_ee_application_setting(elasticsearch_indexing: false)

      expect_any_instance_of(Gitlab::Elastic::Indexer).not_to receive(:run)

      expect(subject.perform(1)).to be_truthy
    end

    it 'removes ES lock on project if we are receiving an initial commit' do
      redis = double('redis').as_null_object
      allow(Gitlab::Redis::SharedState).to receive(:with).and_yield(redis)

      expect(redis).to receive(:srem).with(:elastic_projects_indexing, project.id)

      subject.perform(project.id, Gitlab::Git::BLANK_SHA, nil)
    end

    it 'does not attempt to unlock a project if it is not an initial commit' do
      redis = double('redis').as_null_object
      allow(Gitlab::Redis::SharedState).to receive(:with).and_yield(redis)
      allow(Gitlab::Elastic::Indexer).to receive(:new).and_return(double.as_null_object)

      expect(redis).not_to receive(:srem).with(:elastic_projects_indexing, project.id)

      subject.perform(project.id, 'random', 'otherrandom')
    end
  end
end
