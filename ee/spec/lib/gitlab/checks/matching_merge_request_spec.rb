# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Checks::MatchingMergeRequest do
  describe '#match?' do
    let_it_be(:newrev) { '012345678' }
    let_it_be(:target_branch) { 'feature' }
    let_it_be(:project) { create(:project, :repository) }
    let_it_be(:locked_merge_request) do
      create(:merge_request,
        :locked,
        source_project: project,
        target_project: project,
        target_branch: target_branch,
        in_progress_merge_commit_sha: newrev)
    end

    subject { described_class.new(newrev, target_branch, project) }

    it 'matches a merge request' do
      expect(subject.match?).to be true
    end

    it 'does not match any merge request' do
      matcher = described_class.new(newrev, 'test', project)

      expect(matcher.match?).to be false
    end

    context 'with load balancing enabled', :request_store do
      it 'sticks to the primary' do
        expect(::Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(true)
        expect(::Gitlab::Database::LoadBalancing::Session.current).to receive(:use_primary).and_call_original

        expect(subject.match?).to be true
      end
    end
  end
end
