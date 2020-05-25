# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ProjectSearchResults do
  include SearchHelpers

  let(:user) { create(:user) }
  let(:project) { create(:project) }
  let(:query) { 'hello world' }

  describe 'initialize with empty ref' do
    let(:results) { described_class.new(user, project, query, '') }

    it { expect(results.project).to eq(project) }
    it { expect(results.query).to eq('hello world') }
  end

  describe 'initialize with ref' do
    let(:ref) { 'refs/heads/test' }
    let(:results) { described_class.new(user, project, query, ref) }

    it { expect(results.project).to eq(project) }
    it { expect(results.repository_ref).to eq(ref) }
    it { expect(results.query).to eq('hello world') }
  end

  describe '#formatted_count' do
    using RSpec::Parameterized::TableSyntax

    let(:results) { described_class.new(user, project, query) }

    where(:scope, :count_method, :expected) do
      'blobs'      | :limited_blobs_count    | max_limited_count
      'notes'      | :limited_notes_count    | max_limited_count
      'wiki_blobs' | :wiki_blobs_count       | '1234'
      'commits'    | :commits_count          | max_limited_count
      'projects'   | :limited_projects_count | max_limited_count
      'unknown'    | nil                     | nil
    end

    with_them do
      it 'returns the expected formatted count' do
        expect(results).to receive(count_method).and_return(1234) if count_method
        expect(results.formatted_count(scope)).to eq(expected)
      end
    end

    context 'blobs' do
      it "limits the search to #{described_class::COUNT_LIMIT} items" do
        expect(results).to receive(:blobs).with(limit: described_class::COUNT_LIMIT).and_call_original
        expect(results.formatted_count('blobs')).to eq('0')
      end
    end

    context 'wiki_blobs' do
      it "limits the search to #{described_class::COUNT_LIMIT} items" do
        expect(results).to receive(:wiki_blobs).with(limit: described_class::COUNT_LIMIT).and_call_original
        expect(results.formatted_count('wiki_blobs')).to eq('0')
      end
    end
  end

  shared_examples 'general blob search' do |entity_type, blob_type|
    let(:query) { 'files' }
    subject(:results) { described_class.new(user, project, query).objects(blob_type) }

    context "when #{entity_type} is disabled" do
      let(:project) { disabled_project }

      it "hides #{blob_type} from members" do
        project.add_reporter(user)

        is_expected.to be_empty
      end

      it "hides #{blob_type} from non-members" do
        is_expected.to be_empty
      end
    end

    context "when #{entity_type} is internal" do
      let(:project) { private_project }

      it "finds #{blob_type} for members" do
        project.add_reporter(user)

        is_expected.not_to be_empty
      end

      it "hides #{blob_type} from non-members" do
        is_expected.to be_empty
      end
    end

    it 'finds by name' do
      expect(results.map(&:path)).to include(expected_file_by_path)
    end

    it "loads all blobs for path matches in single batch" do
      expect(Gitlab::Git::Blob).to receive(:batch).once.and_call_original

      results.map(&:data)
    end

    it 'finds by content' do
      blob = results.select { |result| result.path == expected_file_by_content }.flatten.last

      expect(blob.path).to eq(expected_file_by_content)
    end
  end

  shared_examples 'blob search repository ref' do |entity_type, blob_type|
    let(:query) { 'files' }
    let(:file_finder) { double }
    let(:project_branch) { 'project_branch' }

    subject(:results) { described_class.new(user, project, query, repository_ref).objects(blob_type) }

    before do
      allow(entity).to receive(:default_branch).and_return(project_branch)
      allow(file_finder).to receive(:find).and_return([])
    end

    context 'when repository_ref exists' do
      let(:repository_ref) { 'ref_branch' }

      it 'uses it' do
        expect(Gitlab::FileFinder).to receive(:new).with(project, repository_ref).and_return(file_finder)

        results
      end
    end

    context 'when repository_ref is not present' do
      let(:repository_ref) { nil }

      it "uses #{entity_type} repository default reference" do
        expect(Gitlab::FileFinder).to receive(:new).with(project, project_branch).and_return(file_finder)

        results
      end
    end

    context 'when repository_ref is blank' do
      let(:repository_ref) { '' }

      it "uses #{entity_type} repository default reference" do
        expect(Gitlab::FileFinder).to receive(:new).with(project, project_branch).and_return(file_finder)

        results
      end
    end
  end

  shared_examples 'blob search pagination' do |blob_type|
    let(:per_page) { 20 }
    let(:count_limit) { described_class::COUNT_LIMIT }
    let(:file_finder) { instance_double('Gitlab::FileFinder') }
    let(:results) { described_class.new(user, project, query) }
    let(:repository_ref) { 'master' }

    before do
      allow(file_finder).to receive(:find).and_return([])
      expect(Gitlab::FileFinder).to receive(:new).with(project, repository_ref).and_return(file_finder)
    end

    it 'limits search results based on the first page' do
      expect(file_finder).to receive(:find).with(query, content_match_cutoff: count_limit)
      results.objects(blob_type, page: 1, per_page: per_page)
    end

    it 'limits search results based on the second page' do
      expect(file_finder).to receive(:find).with(query, content_match_cutoff: count_limit + per_page)
      results.objects(blob_type, page: 2, per_page: per_page)
    end

    it 'limits search results based on the third page' do
      expect(file_finder).to receive(:find).with(query, content_match_cutoff: count_limit + per_page * 2)
      results.objects(blob_type, page: 3, per_page: per_page)
    end

    it 'uses the per_page value when passed' do
      expect(file_finder).to receive(:find).with(query, content_match_cutoff: count_limit + 10 * 2)
      results.objects(blob_type, page: 3, per_page: 10)
    end
  end

  describe 'blob search' do
    let(:project) { create(:project, :public, :repository) }

    it_behaves_like 'general blob search', 'repository', 'blobs' do
      let(:disabled_project) { create(:project, :public, :repository, :repository_disabled) }
      let(:private_project) { create(:project, :public, :repository, :repository_private) }
      let(:expected_file_by_path) { 'files/images/wm.svg' }
      let(:expected_file_by_content) { 'CHANGELOG' }
    end

    it_behaves_like 'blob search repository ref', 'project', 'blobs' do
      let(:entity) { project }
    end

    it_behaves_like 'blob search pagination', 'blobs'
  end

  describe 'wiki search' do
    let(:project) { create(:project, :public, :wiki_repo) }
    let(:wiki) { build(:project_wiki, project: project) }

    before do
      wiki.create_page('Files/Title', 'Content')
      wiki.create_page('CHANGELOG', 'Files example')
    end

    it_behaves_like 'general blob search', 'wiki', 'wiki_blobs' do
      let(:blob_type) { 'wiki_blobs' }
      let(:disabled_project) { create(:project, :public, :wiki_repo, :wiki_disabled) }
      let(:private_project) { create(:project, :public, :wiki_repo, :wiki_private) }
      let(:expected_file_by_path) { 'Files/Title.md' }
      let(:expected_file_by_content) { 'CHANGELOG.md' }
    end

    it_behaves_like 'blob search repository ref', 'wiki', 'wiki_blobs' do
      let(:entity) { project.wiki }
    end

    it_behaves_like 'blob search pagination', 'wiki_blobs'

    context 'return type' do
      let(:blobs) { [Gitlab::Search::FoundBlob.new(project: project)] }
      let(:results) { described_class.new(user, project, "Files", per_page: 20) }

      before do
        allow(results).to receive(:wiki_blobs).and_return(blobs)
      end

      it 'returns list of FoundWikiPage type object' do
        objects = results.objects('wiki_blobs')

        expect(objects).to be_present
        expect(objects).to all(be_a(Gitlab::Search::FoundWikiPage))
      end
    end
  end

  it 'does not list issues on private projects' do
    issue = create(:issue, project: project)

    results = described_class.new(user, project, issue.title)

    expect(results.objects('issues')).not_to include issue
  end

  describe 'confidential issues' do
    let(:query) { 'issue' }
    let(:author) { create(:user) }
    let(:assignee) { create(:user) }
    let(:non_member) { create(:user) }
    let(:member) { create(:user) }
    let(:admin) { create(:admin) }
    let(:project) { create(:project, :internal) }
    let!(:issue) { create(:issue, project: project, title: 'Issue 1') }
    let!(:security_issue_1) { create(:issue, :confidential, project: project, title: 'Security issue 1', author: author) }
    let!(:security_issue_2) { create(:issue, :confidential, title: 'Security issue 2', project: project, assignees: [assignee]) }

    it 'does not list project confidential issues for non project members' do
      results = described_class.new(non_member, project, query)
      issues = results.objects('issues')

      expect(issues).to include issue
      expect(issues).not_to include security_issue_1
      expect(issues).not_to include security_issue_2
      expect(results.limited_issues_count).to eq 1
    end

    it 'does not list project confidential issues for project members with guest role' do
      project.add_guest(member)

      results = described_class.new(member, project, query)
      issues = results.objects('issues')

      expect(issues).to include issue
      expect(issues).not_to include security_issue_1
      expect(issues).not_to include security_issue_2
      expect(results.limited_issues_count).to eq 1
    end

    it 'lists project confidential issues for author' do
      results = described_class.new(author, project, query)
      issues = results.objects('issues')

      expect(issues).to include issue
      expect(issues).to include security_issue_1
      expect(issues).not_to include security_issue_2
      expect(results.limited_issues_count).to eq 2
    end

    it 'lists project confidential issues for assignee' do
      results = described_class.new(assignee, project, query)
      issues = results.objects('issues')

      expect(issues).to include issue
      expect(issues).not_to include security_issue_1
      expect(issues).to include security_issue_2
      expect(results.limited_issues_count).to eq 2
    end

    it 'lists project confidential issues for project members' do
      project.add_developer(member)

      results = described_class.new(member, project, query)
      issues = results.objects('issues')

      expect(issues).to include issue
      expect(issues).to include security_issue_1
      expect(issues).to include security_issue_2
      expect(results.limited_issues_count).to eq 3
    end

    it 'lists all project issues for admin' do
      results = described_class.new(admin, project, query)
      issues = results.objects('issues')

      expect(issues).to include issue
      expect(issues).to include security_issue_1
      expect(issues).to include security_issue_2
      expect(results.limited_issues_count).to eq 3
    end
  end

  describe 'notes search' do
    it 'lists notes' do
      project = create(:project, :public)
      note = create(:note, project: project)

      results = described_class.new(user, project, note.note)

      expect(results.objects('notes')).to include note
    end

    it "doesn't list issue notes when access is restricted" do
      project = create(:project, :public, :issues_private)
      note = create(:note_on_issue, project: project)

      results = described_class.new(user, project, note.note)

      expect(results.objects('notes')).not_to include note
    end

    it "doesn't list merge_request notes when access is restricted" do
      project = create(:project, :public, :merge_requests_private)
      note = create(:note_on_merge_request, project: project)

      results = described_class.new(user, project, note.note)

      expect(results.objects('notes')).not_to include note
    end
  end

  describe '#limited_notes_count' do
    let(:project) { create(:project, :public) }
    let(:note) { create(:note_on_issue, project: project) }
    let(:results) { described_class.new(user, project, note.note) }

    context 'when count_limit is lower than total amount' do
      before do
        allow(results).to receive(:count_limit).and_return(1)
      end

      it 'calls note finder once to get the limited amount of notes' do
        expect(results).to receive(:notes_finder).once.and_call_original
        expect(results.limited_notes_count).to eq(1)
      end
    end

    context 'when count_limit is higher than total amount' do
      it 'calls note finder multiple times to get the limited amount of notes' do
        project = create(:project, :public)
        note = create(:note_on_issue, project: project)

        results = described_class.new(user, project, note.note)

        expect(results).to receive(:notes_finder).exactly(4).times.and_call_original
        expect(results.limited_notes_count).to eq(1)
      end
    end
  end

  describe '#commits_count' do
    let(:project) { create(:project, :public, :repository) }

    it 'limits the number of commits requested' do
      expect(project.repository)
        .to receive(:find_commits_by_message)
        .with(anything, anything, anything, described_class::COUNT_LIMIT)
        .and_call_original

      described_class.new(user, project, '.').commits_count
    end
  end

  # Examples for commit access level test
  #
  # params:
  # * search_phrase
  # * commit
  #
  shared_examples 'access restricted commits' do
    context 'when project is internal' do
      let(:project) { create(:project, :internal, :repository) }

      it 'does not search if user is not authenticated' do
        commits = described_class.new(nil, project, search_phrase).objects('commits')

        expect(commits).to be_empty
      end

      it 'searches if user is authenticated' do
        commits = described_class.new(user, project, search_phrase).objects('commits')

        expect(commits).to contain_exactly commit
      end
    end

    context 'when project is private' do
      let!(:creator) { create(:user, username: 'private-project-author') }
      let!(:private_project) { create(:project, :private, :repository, creator: creator, namespace: creator.namespace) }
      let(:team_master) do
        user = create(:user, username: 'private-project-master')
        private_project.add_maintainer(user)
        user
      end
      let(:team_reporter) do
        user = create(:user, username: 'private-project-reporter')
        private_project.add_reporter(user)
        user
      end

      it 'does not show commit to stranger' do
        commits = described_class.new(nil, private_project, search_phrase).objects('commits')

        expect(commits).to be_empty
      end

      context 'team access' do
        it 'shows commit to creator' do
          commits = described_class.new(creator, private_project, search_phrase).objects('commits')

          expect(commits).to contain_exactly commit
        end

        it 'shows commit to master' do
          commits = described_class.new(team_master, private_project, search_phrase).objects('commits')

          expect(commits).to contain_exactly commit
        end

        it 'shows commit to reporter' do
          commits = described_class.new(team_reporter, private_project, search_phrase).objects('commits')

          expect(commits).to contain_exactly commit
        end
      end
    end
  end

  describe 'commit search' do
    context 'pagination' do
      let(:project) { create(:project, :public, :repository) }

      it 'returns the correct results for each page' do
        expect(results_page(1)).to contain_exactly(commit('b83d6e391c22777fca1ed3012fce84f633d7fed0'))

        expect(results_page(2)).to contain_exactly(commit('498214de67004b1da3d820901307bed2a68a8ef6'))

        expect(results_page(3)).to contain_exactly(commit('1b12f15a11fc6e62177bef08f47bc7b5ce50b141'))
      end

      it 'returns the correct number of pages' do
        expect(results_page(1).total_pages).to eq(project.repository.commit_count)
      end

      context 'limiting requested commits' do
        context 'on page 1' do
          it "limits to #{described_class::COUNT_LIMIT}" do
            expect(project.repository)
              .to receive(:find_commits_by_message)
              .with(anything, anything, anything, described_class::COUNT_LIMIT)
              .and_call_original

            results_page(1)
          end
        end

        context 'on subsequent pages' do
          it "limits to #{described_class::COUNT_LIMIT} plus page offset" do
            expect(project.repository)
              .to receive(:find_commits_by_message)
              .with(anything, anything, anything, described_class::COUNT_LIMIT + 1)
              .and_call_original

            results_page(2)
          end
        end
      end

      def results_page(page)
        described_class.new(user, project, '.').objects('commits', per_page: 1, page: page)
      end

      def commit(hash)
        project.repository.commit(hash)
      end
    end

    context 'by commit message' do
      let(:project) { create(:project, :public, :repository) }
      let(:commit) { project.repository.commit('59e29889be61e6e0e5e223bfa9ac2721d31605b8') }
      let(:message) { 'Sorry, I did a mistake' }

      it 'finds commit by message' do
        commits = described_class.new(user, project, message).objects('commits')

        expect(commits).to contain_exactly commit
      end

      it 'handles when no commit match' do
        commits = described_class.new(user, project, 'not really an existing description').objects('commits')

        expect(commits).to be_empty
      end

      it_behaves_like 'access restricted commits' do
        let(:search_phrase) { message }
        let(:commit) { project.repository.commit('59e29889be61e6e0e5e223bfa9ac2721d31605b8') }
      end
    end

    context 'by commit hash' do
      let(:project) { create(:project, :public, :repository) }
      let(:commit) { project.repository.commit('0b4bc9a') }

      commit_hashes = { short: '0b4bc9a', full: '0b4bc9a49b562e85de7cc9e834518ea6828729b9' }

      commit_hashes.each do |type, commit_hash|
        it "shows commit by #{type} hash id" do
          commits = described_class.new(user, project, commit_hash).objects('commits')

          expect(commits).to contain_exactly commit
        end
      end

      it 'handles not existing commit hash correctly' do
        commits = described_class.new(user, project, 'deadbeef').objects('commits')

        expect(commits).to be_empty
      end

      it_behaves_like 'access restricted commits' do
        let(:search_phrase) { '0b4bc9a49' }
        let(:commit) { project.repository.commit('0b4bc9a') }
      end
    end
  end

  describe 'user search' do
    it 'returns the user belonging to the project matching the search query' do
      project = create(:project)

      user1 = create(:user, username: 'gob_bluth')
      create(:project_member, :developer, user: user1, project: project)

      user2 = create(:user, username: 'michael_bluth')
      create(:project_member, :developer, user: user2, project: project)

      create(:user, username: 'gob_2018')

      result = described_class.new(user, project, 'gob').objects('users')

      expect(result).to eq [user1]
    end

    it 'returns the user belonging to the group matching the search query' do
      group = create(:group)
      project = create(:project, namespace: group)

      user1 = create(:user, username: 'gob_bluth')
      create(:group_member, :developer, user: user1, group: group)

      create(:user, username: 'gob_2018')

      result = described_class.new(user, project, 'gob').objects('users')

      expect(result).to eq [user1]
    end
  end
end
