# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::BackgroundMigration::BackfillSnippetRepositories, :migration, schema: 2020_02_26_162723 do
  let(:gitlab_shell) { Gitlab::Shell.new }
  let(:users) { table(:users) }
  let(:snippets) { table(:snippets) }

  let(:user) { users.create(id: 1, email: 'user@example.com', projects_limit: 10, username: 'test', name: 'Test') }
  let!(:snippet_with_repo) { snippets.create(id: 1, type: 'PersonalSnippet', author_id: user.id, file_name: file_name, content: content) }
  let!(:snippet_with_empty_repo) { snippets.create(id: 2, type: 'PersonalSnippet', author_id: user.id, file_name: file_name, content: content) }
  let!(:snippet_without_repo) { snippets.create(id: 3, type: 'PersonalSnippet', author_id: user.id, file_name: file_name, content: content) }

  let(:file_name) { 'file_name.rb' }
  let(:content) { 'content' }
  let(:ids) { Snippet.pluck('MIN(id)', 'MAX(id)').first }
  let(:service) { described_class.new }

  subject { service.perform(*ids) }

  before do
    allow(snippet_with_repo).to receive(:disk_path).and_return(disk_path(snippet_with_repo))

    TestEnv.copy_repo(snippet_with_repo,
                      bare_repo: TestEnv.factory_repo_path_bare,
                      refs: TestEnv::BRANCH_SHA)
  end

  after do
    raw_repository(snippet_with_repo).remove
    raw_repository(snippet_without_repo).remove
    raw_repository(snippet_with_empty_repo).remove
  end

  describe '#perform' do
    it 'logs successful migrated snippets' do
      expect_next_instance_of(Gitlab::BackgroundMigration::Logger) do |instance|
        expect(instance).to receive(:info).exactly(3).times
      end

      subject
    end

    it 'logs errors' do
      allow(service).to receive(:create_commit).and_raise(StandardError)

      expect_next_instance_of(Gitlab::BackgroundMigration::Logger) do |instance|
        expect(instance).to receive(:error).exactly(3).times
      end

      subject
    end

    it "retries #{described_class::MAX_RETRIES} times the operation if it fails" do
      allow(service).to receive(:create_commit).and_raise(StandardError)

      expect(service).to receive(:create_commit).exactly(Snippet.count * described_class::MAX_RETRIES).times

      subject
    end

    context 'when snippet has repository' do
      it 'creates the file if it does not exist' do
        count = ls_files(snippet_with_repo).count

        expect(blob_at(snippet_with_repo, file_name)).to be_nil

        subject

        blob = blob_at(snippet_with_repo, file_name)

        aggregate_failures do
          expect(blob).not_to be_nil
          expect(blob.data).to eq content
          expect(ls_files(snippet_with_repo).count).to eq count + 1
        end
      end

      context 'when the file exists' do
        let(:file_name) { 'CHANGELOG' }

        it 'overrides the content' do
          expect(blob_at(snippet_with_repo, file_name)).not_to be_nil

          subject

          expect(blob_at(snippet_with_repo, file_name).data).to eq content
        end
      end
    end

    shared_examples 'commits the file to the repository' do
      it do
        subject

        blob = blob_at(snippet, file_name)

        aggregate_failures do
          expect(blob).not_to be_nil
          expect(blob.data).to eq content
        end
      end
    end

    context 'when snippet has an empty repo' do
      before do
        raw_repository(snippet_with_empty_repo).create_repository

        expect(repository_exists?(snippet_with_empty_repo)).to be_truthy
      end

      it_behaves_like 'commits the file to the repository' do
        let(:snippet) { snippet_with_empty_repo }
      end
    end

    context 'when snippet does not have a repository' do
      it 'creates the repository' do
        expect(repository_exists?(snippet_without_repo)).to be_falsey

        subject

        expect(repository_exists?(snippet_without_repo)).to be_truthy
      end

      it_behaves_like 'commits the file to the repository' do
        let(:snippet) { snippet_without_repo }
      end
    end
  end

  def blob_at(snippet, path)
    raw_repository(snippet).blob_at('master', path)
  end

  def repository_exists?(snippet)
    gitlab_shell.repository_exists?('default', "#{disk_path(snippet)}.git")
  end

  def raw_repository(snippet)
    Gitlab::Git::Repository.new('default',
                                "#{disk_path(snippet)}.git",
                                Gitlab::GlRepository::SNIPPET.identifier_for_container(snippet),
                                "@snippets/#{snippet.id}")
  end

  def hashed_repository(snippet)
    Storage::Hashed.new(snippet, prefix: '@snippets')
  end

  def disk_path(snippet)
    hashed_repository(snippet).disk_path
  end

  def ls_files(snippet)
    raw_repository(snippet).ls_files(nil)
  end
end
