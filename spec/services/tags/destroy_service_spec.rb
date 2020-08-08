# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tags::DestroyService do
  let(:project) { create(:project, :repository) }
  let(:repository) { project.repository }
  let(:user) { create(:user) }
  let(:service) { described_class.new(project, user) }

  describe '#execute' do
    subject { service.execute(tag_name) }

    it 'removes the tag' do
      expect(repository).to receive(:before_remove_tag)
      expect(service).to receive(:success)

      service.execute('v1.1.0')
    end

    it 'publishes a domain event' do
      event = double(:event)

      expect(::Repositories::TagDeletedEvent)
        .to receive(:new)
        .with(data: { project_id: project.id, user_id: user.id, ref: 'refs/tags/v1.1.0' })
        .and_return(event)

      expect(Gitlab::EventStore).to receive(:publish).with(event)

      service.execute('v1.1.0')
    end

    it 'unlocks artifacts through Ci::UnlockArtifactsWorker subscriber', :sidekiq_inline do
      create(:ci_ref, project: project, ref_path: 'refs/tags/v1.1.0')

      expect(Ci::UnlockArtifactsService).to receive(:new).with(project, user).and_call_original

      service.execute('v1.1.0')
    end

    context 'when there is an associated release on the tag' do
      let(:tag) { repository.tags.first }
      let(:tag_name) { tag.name }

      before do
        project.add_maintainer(user)
        create(:release, tag: tag_name, project: project)
      end

      it 'destroys the release' do
        expect { subject }.to change { project.releases.count }.by(-1)
      end
    end
  end
end
