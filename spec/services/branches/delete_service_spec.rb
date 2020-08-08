# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Branches::DeleteService do
  let(:project) { create(:project, :repository) }
  let(:repository) { project.repository }
  let(:user) { create(:user) }

  subject(:service) { described_class.new(project, user) }

  shared_examples 'a deleted branch' do |branch_name|
    it 'removes the branch' do
      expect(branch_exists?(branch_name)).to be true

      result = service.execute(branch_name)

      expect(result.status).to eq :success
      expect(branch_exists?(branch_name)).to be false
    end

    it 'publishes a domain event' do
      event = double(:event)

      expect(::Repositories::BranchDeletedEvent)
        .to receive(:new)
        .with(data: { project_id: project.id, user_id: user.id, ref: "refs/heads/#{branch_name}" })
        .and_return(event)

      expect(Gitlab::EventStore).to receive(:publish).with(event)

      service.execute(branch_name)
    end

    it 'unlocks artifacts through Ci::UnlockArtifactsWorker subscriber', :sidekiq_inline do
      create(:ci_ref, project: project, ref_path: "refs/heads/#{branch_name}")

      expect(Ci::UnlockArtifactsService).to receive(:new).with(project, user).and_call_original

      service.execute(branch_name)
    end
  end

  describe '#execute' do
    context 'when user has access to push to repository' do
      before do
        project.add_developer(user)
      end

      it_behaves_like 'a deleted branch', 'feature'
    end

    context 'when user does not have access to push to repository' do
      it 'does not remove branch' do
        expect(branch_exists?('feature')).to be true

        result = service.execute('feature')

        expect(result.status).to eq :error
        expect(result.message).to eq 'You dont have push access to repo'
        expect(branch_exists?('feature')).to be true
      end
    end
  end

  def branch_exists?(branch_name)
    repository.ref_exists?("refs/heads/#{branch_name}")
  end
end
