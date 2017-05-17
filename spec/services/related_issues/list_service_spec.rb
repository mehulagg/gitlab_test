require 'spec_helper'

describe RelatedIssues::ListService, service: true do
  let(:user) { create :user }
  let(:project) { create(:project_empty_repo) }
  let(:issue) { create :issue, project: project }

  before do
    project.team << [user, :developer]
  end

  describe '#execute' do
    subject { described_class.new(issue, user).execute }

    context 'user can see all issues' do
      let(:issue_b) { create :issue, project: project }
      let(:issue_c) { create :issue, project: project }
      let(:issue_d) { create :issue, project: project }

      let!(:related_issue_c) do
        create(:related_issue, id: 999,
                               issue: issue_d,
                               related_issue: issue)
      end

      let!(:related_issue_b) do
        create(:related_issue, id: 998,
                               issue: issue,
                               related_issue: issue_c)
      end

      let!(:related_issue_a) do
        create(:related_issue, id: 997,
                               issue: issue,
                               related_issue: issue_b)
      end

      it 'verifies number of queries' do
        recorded = ActiveRecord::QueryRecorder.new { subject }
        expect(recorded.count).to be_within(1).of(39)
      end

      it 'returns related issues JSON' do
        expect(subject.size).to eq(3)

        expect(subject[0]).to eq(
          {
            id: issue_b.id,
            iid: issue_b.iid,
            title: issue_b.title,
            state: issue_b.state,
            path: "/#{project.full_path}/issues/#{issue_b.iid}",
            project_path: issue_b.project.path,
            namespace_full_path: issue_b.project.namespace.full_path,
            destroy_relation_path: "/#{project.full_path}/issues/#{issue_b.iid}/related_issues/#{related_issue_a.id}"
          }
        )

        expect(subject[1]).to eq(
          {
            id: issue_c.id,
            iid: issue_c.iid,
            title: issue_c.title,
            state: issue_c.state,
            path: "/#{project.full_path}/issues/#{issue_c.iid}",
            project_path: issue_c.project.path,
            namespace_full_path: issue_c.project.namespace.full_path,
            destroy_relation_path: "/#{project.full_path}/issues/#{issue_c.iid}/related_issues/#{related_issue_b.id}"
          }
        )

        expect(subject[2]).to eq(
          {
            id: issue_d.id,
            iid: issue_d.iid,
            title: issue_d.title,
            state: issue_d.state,
            path: "/#{project.full_path}/issues/#{issue_d.iid}",
            project_path: issue_d.project.path,
            namespace_full_path: issue_d.project.namespace.full_path,
            destroy_relation_path: "/#{project.full_path}/issues/#{issue_d.iid}/related_issues/#{related_issue_c.id}"
          }
        )
      end
    end

    context 'referencing issue with removed relationships' do
      context 'when referenced a deleted issue' do
        let(:issue_b) { create :issue, project: project }
        let!(:related_issue) do
          create(:related_issue, issue: issue, related_issue: issue_b)
        end

        it 'ignores issue' do
          issue_b.destroy!

          is_expected.to eq([])
        end
      end

      context 'when referenced an issue with deleted project' do
        let(:issue_b) { create :issue, project: project }
        let!(:related_issue) do
          create(:related_issue, issue: issue, related_issue: issue_b)
        end

        it 'ignores issue' do
          project.destroy!

          is_expected.to eq([])
        end
      end

      context 'when referenced an issue with deleted namespace' do
        let(:issue_b) { create :issue, project: project }
        let!(:related_issue) do
          create(:related_issue, issue: issue, related_issue: issue_b)
        end

        it 'ignores issue' do
          project.namespace.destroy!

          is_expected.to eq([])
        end
      end
    end

    context 'user cannot see relations' do
      context 'when user cannot see the referenced issue' do
        let!(:related_issue) do
          create(:related_issue, issue: issue)
        end

        it 'returns an empty list' do
          is_expected.to eq([])
        end
      end

      context 'when user cannot see the issue that referenced' do
        let!(:related_issue) do
          create(:related_issue, related_issue: issue)
        end

        it 'returns an empty list' do
          is_expected.to eq([])
        end
      end
    end

    context 'remove relations' do
      let!(:related_issue) do
        create(:related_issue, issue: issue, related_issue: referenced_issue)
      end

      context 'when user can admin related issues on one project' do
        let(:unauthorized_project) { create :empty_project }
        let(:referenced_issue) { create :issue, project: unauthorized_project }

        before do
          # User can just see related issues
          unauthorized_project.team << [user, :guest]
        end

        it 'returns no destroy relation path' do
          expect(subject.first[:destroy_relation_path]).to be_nil
        end
      end

      context 'when user can admin related issues on both projects' do
        let(:referenced_issue) { create :issue, project: project }

        it 'returns related issue destroy relation path' do
          expect(subject.first[:destroy_relation_path])
            .to eq("/#{project.full_path}/issues/#{referenced_issue.iid}/related_issues/#{related_issue.id}")
        end
      end
    end
  end
end
