require 'spec_helper'

describe Git::BranchPushService do
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

    context 'deleted branch' do
      let(:newrev) { blankrev }

      it 'handles when remote branch exists' do
        allow(project.repository).to receive(:commit).and_call_original
        allow(project.repository).to receive(:commit).with("master").and_return(nil)
        expect(project.repository).to receive(:commit).with("refs/remotes/upstream/master").and_return(sample_commit)

        subject.execute
      end
    end

    context 'ElasticSearch indexing' do
      it "does not trigger indexer when push to non-default branch" do
        expect_any_instance_of(Gitlab::Elastic::Indexer).not_to receive(:run)

        execute_service(project, user, oldrev, newrev, 'refs/heads/other')
      end

      it "triggers indexer when push to default branch" do
        expect_any_instance_of(Gitlab::Elastic::Indexer).to receive(:run)

        execute_service(project, user, oldrev, newrev, ref)
      end
    end
  end

  def execute_service(project, user, oldrev, newrev, ref)
    service = described_class.new(project, user, oldrev: oldrev, newrev: newrev, ref: ref)
    service.execute
    service
  end
end
