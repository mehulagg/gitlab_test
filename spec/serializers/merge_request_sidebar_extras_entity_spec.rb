# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequestSidebarExtrasEntity do
  let_it_be(:assignee, reload: true) { create(:user) }
  let_it_be(:reviewer, reload: true) { create(:user) }

  let(:user) { create(:user) }
  let(:project) { create :project, :repository }
  let(:merge_request) do
    create(:merge_request, source_project: project,
                           target_project: project,
                           assignees: [assignee],
                           reviewers: [reviewer])
  end

  let(:request) { double('request', current_user: user, project: project) }

  let(:entity) { described_class.new(merge_request, request: request).as_json }

  describe '#assignees' do
    it 'contains assignees attributes' do
      expect(entity[:assignees].count).to be 1
      expect(entity[:assignees].first.keys).to include(
        :id, :name, :username, :state, :avatar_url, :web_url, :can_merge
      )
    end
  end

  describe '#reviewers' do
    context 'when merge_request_reviewers feature is disabled' do
      it 'does not contain assignees attributes' do
        stub_licensed_features(merge_request_reviewers: false)

        expect(entity[:reviewers]).to be_nil
      end
    end

    context 'when merge_request_reviewers feature is enabled' do
      it 'does not include code navigation properties' do
        stub_licensed_features(merge_request_reviewers: true)

        expect(entity[:reviewers].count).to be 1
        expect(entity[:reviewers].first.keys).to include(
          :id, :name, :username, :state, :avatar_url, :web_url, :can_merge
        )
      end
    end
  end
end
