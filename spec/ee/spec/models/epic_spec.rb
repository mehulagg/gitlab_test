require 'spec_helper'

describe Epic do
  describe 'associations' do
    subject { build(:epic) }

    it { is_expected.to belong_to(:author).class_name('User') }
    it { is_expected.to belong_to(:assignee).class_name('User') }
    it { is_expected.to belong_to(:group) }
  end

  describe 'validations' do
    subject { create(:epic) }

    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'modules' do
    subject { described_class }

    it { is_expected.to include_module(InternalId) }
  end

  describe '#issues' do
    let(:user) { create(:user) }
    let(:group) { create(:group, :private) }
    let(:project) { create(:project, group: group) }
    let(:project2) { create(:project, group: group) }

    let!(:epic) { create(:epic, group: group) }
    let!(:issue) { create(:issue, project: project)}
    let!(:lone_issue) { create(:issue, project: project)}
    let!(:other_issue) { create(:issue, project: project2)}
    let!(:epic_issues) do
      [
        create(:epic_issue, epic: epic, issue: issue),
        create(:epic_issue, epic: epic, issue: other_issue)
      ]
    end

    let(:result) { epic.issues(user) }

    it 'returns all issues if a user has access to them' do
      group.add_developer(user)

      expect(result.count).to eq(2)
      expect(result.map(&:id)).to match_array([issue.id, other_issue.id])
      expect(result.map(&:epic_issue_id)).to match_array(epic_issues.map(&:id))
    end

    it 'does not return issues user can not see' do
      project.add_developer(user)

      expect(result.count).to eq(1)
      expect(result.map(&:id)).to match_array([issue.id])
      expect(result.map(&:epic_issue_id)).to match_array([epic_issues.first.id])
    end
  end

  describe '#to_reference' do
    let(:group) { create(:group, path: 'group-a') }
    let(:epic) { create(:epic, iid: 1, group: group) }

    context 'when nil argument' do
      it 'returns epic id' do
        expect(epic.to_reference).to eq('&1')
      end
    end

    context 'when group argument equals epic group' do
      it 'returns epic id' do
        expect(epic.to_reference(epic.group)).to eq('&1')
      end
    end

    context 'when group argument differs from epic group' do
      it 'returns complete path to the epic' do
        expect(epic.to_reference(create(:group))).to eq('group-a&1')
      end
    end

    context 'when full is true' do
      it 'returns complete path to the epic' do
        expect(epic.to_reference(full: true)).to             eq('group-a&1')
        expect(epic.to_reference(epic.group, full: true)).to eq('group-a&1')
        expect(epic.to_reference(group, full: true)).to      eq('group-a&1')
      end
    end
  end

  context 'mentioning other objects' do
    let(:group)   { create(:group) }
    let(:epic) { create(:epic, group: group) }

    let(:project) { create(:project, :repository, :public) }
    let(:mentioned_issue) { create(:issue, project: project) }
    let(:mentioned_mr)     { create(:merge_request, source_project: project) }
    let(:mentioned_commit) { project.commit("HEAD~1") }

    let(:backref_text) { "epic #{epic.to_reference}" }
    let(:ref_text) do
      <<-MSG.strip_heredoc
        These are simple references:
          Issue:  #{mentioned_issue.to_reference(group)}
          Merge Request:  #{mentioned_mr.to_reference(group)}
          Commit: #{mentioned_commit.to_reference(group)}

        This is a self-reference and should not be mentioned at all:
          Self: #{backref_text}
      MSG
    end

    before do
      epic.description = ref_text
      epic.save
    end

    it 'creates new system notes for cross references' do
      [mentioned_issue, mentioned_mr, mentioned_commit].each do |newref|
        expect(SystemNoteService).to receive(:cross_reference)
          .with(newref, epic, epic.author)
      end

      epic.create_new_cross_references!(epic.author)
    end
  end
end
