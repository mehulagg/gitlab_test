# frozen_string_literal: true

require 'spec_helper'

describe API::Entities::Release do
  let_it_be(:project) { create(:project) }
  let_it_be(:release) { create(:release, :with_evidence, project: project) }
  let(:evidence) { release.evidences.first }
  let(:user) { create(:user) }
  let(:entity) { described_class.new(release, current_user: user) }
  let(:subject_evidence) { subject[:evidences].first }

  subject { entity.as_json }

  describe 'evidences' do
    context 'when the current user can download code' do
      it 'exposes the evidence sha and the json path' do
        allow(Ability).to receive(:allowed?).and_call_original
        allow(Ability).to receive(:allowed?)
          .with(user, :download_code, project).and_return(true)

        expect(subject_evidence[:sha]).to eq(evidence.summary_sha)
        expect(subject_evidence[:collected_at]).to eq(evidence.collected_at)
        expect(subject_evidence[:filepath]).to eq(
          Gitlab::Routing.url_helpers.namespace_project_release_evidence_url(
            namespace_id: project.namespace_id,
            project_id: project,
            release_tag: release,
            id: evidence.id,
            format: :json))
      end
    end

    context 'when the current user cannot download code' do
      it 'does not expose any evidence data' do
        allow(Ability).to receive(:allowed?).and_call_original
        allow(Ability).to receive(:allowed?)
          .with(user, :download_code, project).and_return(false)

        expect(subject.keys).not_to include(:evidences)
      end
    end
  end
end
