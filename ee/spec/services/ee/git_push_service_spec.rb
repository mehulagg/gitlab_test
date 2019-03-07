require 'spec_helper'

describe GitPushService do
  include RepoHelpers

  set(:user)     { create(:user) }
  let(:blankrev) { Gitlab::Git::BLANK_SHA }
  let(:oldrev)   { sample_commit.parent_id }
  let(:newrev)   { sample_commit.id }
  let(:ref)      { 'refs/heads/master' }

  context 'with pull project' do
    set(:project) { create(:project, :repository, :mirror) }

    subject do
      described_class.new(project, user, oldrev: oldrev, newrev: newrev, ref: ref)
    end

    before do
      allow(project.repository).to receive(:commit).and_call_original
      allow(project.repository).to receive(:commit).with("master").and_return(nil)
    end

    context 'deleted branch' do
      let(:newrev) { blankrev }

      it 'handles when remote branch exists' do
        expect(project.repository).to receive(:commit).with("refs/remotes/upstream/master").and_return(sample_commit)

        subject.execute
      end
    end

    context 'ElasticSearch indexing' do
      before do
        stub_ee_application_setting(elasticsearch_indexing?: true)
      end

      context 'when it is the first push in a new project' do
        let(:oldrev) { blankrev }
        let(:redis) { double('redis').as_null_object }

        it 'locks down the project' do
          allow(Gitlab::Redis::SharedState).to receive(:with).and_yield(redis)
          allow(redis).to receive(:sismember).with(:elastic_projects_indexing, project.id).and_return(false)

          expect(redis).to receive(:sadd).with(:elastic_projects_indexing, project.id)
          expect(ElasticCommitIndexerWorker).to receive(:perform_async).with(project.id, blankrev, nil)

          subject.execute
        end
      end

      context 'when the project is locked by elastic.rake', :clean_gitlab_redis_shared_state do
        before do
          Gitlab::Redis::SharedState.with { |redis| redis.sadd(:elastic_projects_indexing, project.id) }
        end

        it 'does not run ElasticCommitIndexerWorker' do
          expect(ElasticCommitIndexerWorker).not_to receive(:perform_async)

          subject.execute
        end
      end

      it 'runs ElasticCommitIndexerWorker' do
        expect(ElasticCommitIndexerWorker).to receive(:perform_async).with(project.id, oldrev, newrev)

        subject.execute
      end
    end
  end
end
