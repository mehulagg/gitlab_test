# frozen_string_literal: true

require 'spec_helper'

describe Analytics::GroupActivityCalculator do
  subject { described_class.new(group, current_user) }

  set(:group) { create(:group) }
  set(:current_user) { create(:user) }
  set(:project) { create(:project, group: group) }
  set(:secret_project) { create(:project, group: group) }

  before do
    group.add_developer(current_user)
    project.add_developer(current_user)
  end

  context 'with issues' do
    let(:recent_issue) { create(:issue, project: project) }
    let(:old_issue) { create(:issue, project: project) }
    let(:secret_issue) { create(:issue, project: secret_project) }

    before do
      old_issue.update!(created_at: 100.days.ago)
    end

    it 'only returns the count of recent, user accessible issues' do
      expect(subject.issues_count).to eq 1
      expect(subject.merge_requests_count).to eq 0
    end
  end

  context 'with merge requests' do
    let(:recent_mr) { create(:merge_request, source_project: project) }
    let(:old_mr) { create(:merge_request, source_project: project) }
    let(:secret_mr) { create(:merge_request, source_project: secret_project) }

    before do
      old_mr.update!(created_at: 100.days.ago)
    end

    it 'only returns the count of recent, user accessible merge requests' do
      expect(subject.merge_requests_count).to eq 1
      expect(subject.issues_count).to eq 0
    end
  end
end
