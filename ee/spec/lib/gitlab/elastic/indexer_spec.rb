# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Elastic::Indexer, :elastic_stub do
  shared_examples_for 'repository indexer' do
    let(:head_commit) { repository.commit }
    let(:head_sha) { head_commit&.sha }

    let(:popen_success) { [[''], 0] }
    let(:popen_failure) { [['error'], 1] }

    context 'empty repository' do
      let(:project) { create(:project) }

      it 'updates the index status without running the indexer' do
        expect_popen.never

        run

        expect_index_status(Gitlab::Git::BLANK_SHA)
      end
    end

    context 'repository has unborn head' do
      before do
        allow(repository).to receive(:exists?).and_return(false)
      end

      it 'updates the index status without running the indexer' do
        expect_popen.never

        run

        expect_index_status(Gitlab::Git::BLANK_SHA)
      end
    end

    context 'repository with data' do
      before do
        if wiki
          # Create initial commits, we need at least two
          project.wiki.create_page('foo.md', '# foo')
          project.wiki.create_page('bar.md', '# bar')
        end
      end

      it 'runs the indexing command and creates the index status' do
        expect_popen.and_return(popen_success)

        run(head_sha)

        expect_index_status(head_sha)
      end

      context 'when index status exists' do
        before do
          project.index_statuses.create(elasticsearch_index: current_es_index, last_commit_column => last_commit)
        end

        context 'when last commit exists' do
          let(:last_commit) { head_commit.parent_ids.first }

          it 'uses last_commit as from_sha' do
            expect_popen(from_sha: last_commit).and_return(popen_success)

            run(head_sha)

            expect_index_status(head_sha)
          end
        end

        context 'when last commit is blank' do
          let(:last_commit) { nil }

          it 'deletes indexed data and starts from scratch' do
            expect_delete_index
            expect_popen.and_return(popen_success)

            run(head_sha)

            expect_index_status(head_sha)
          end
        end

        context 'when last commit is not present in the repository' do
          let(:last_commit) { '12345678' }

          it 'deletes indexed data and starts from scratch' do
            expect_delete_index
            expect_popen.and_return(popen_success)

            run(head_sha)

            expect_index_status(head_sha)
          end
        end

        context 'when repository is empty' do
          let(:last_commit) { nil }

          before do
            repository.remove
          end

          it 'deletes indexed data without running the indexer' do
            expect_delete_index
            expect_popen.never

            run(head_sha)

            expect_index_status(Gitlab::Git::BLANK_SHA)
          end
        end
      end

      it 'updates the index status when the indexing is a success' do
        expect_popen.and_return(popen_success)

        run(head_sha)

        expect_index_status(head_sha)
      end

      it 'leaves the index status untouched when indexing a non-HEAD commit' do
        sha = repository.commit('HEAD~1').sha

        expect_popen(to_sha: sha).and_return(popen_success)

        run(sha)

        expect_index_status(nil)
      end

      it 'leaves the index status untouched when the indexing fails' do
        expect_popen.and_return(popen_failure)

        expect { run(head_sha) }.to raise_error(Gitlab::Elastic::Indexer::Error)

        expect(current_index_status).to be_nil
      end

      context 'reverting a change', :elastic do
        let(:user) { project.owner }

        before do
          stub_ee_application_setting(elasticsearch_indexing: true)
        end

        def change_repository_and_index
          yield

          current_sha = repository.commit('master').sha

          run(current_sha)
          Gitlab::Elastic::Helper.refresh_index
        end

        def indexed_file_paths_for(term)
          blobs =
            if wiki
              ProjectWiki.elastic_search(term, type: :wiki_blob)[:wiki_blobs]
            else
              Repository.elastic_search(term, type: :blob)[:blobs]
            end

          blobs[:results].response.map do |blob|
            blob['_source']['blob']['path']
          end
        end

        context 'when last indexed commit is no longer in repository' do
          before do
            ElasticIndexerWorker.new.perform('index', 'Project', project.id, project.es_id)
          end

          it 'reindexes from scratch' do
            sha_for_reset = nil

            change_repository_and_index do
              sha_for_reset = repository.create_file(user, '12', '', message: '12', branch_name: 'master')
              repository.create_file(user, '23', '', message: '23', branch_name: 'master')
            end

            expect(indexed_file_paths_for('12')).to include('12')
            expect(indexed_file_paths_for('23')).to include('23')

            current_index_status.update!(last_commit_column => '____________')

            change_repository_and_index do
              repository.write_ref('master', sha_for_reset)
            end

            expect(indexed_file_paths_for('12')).to include('12')
            expect(indexed_file_paths_for('23')).not_to include('23')
          end
        end

        context 'when branch is reset to an earlier commit' do
          before do
            change_repository_and_index do
              repository.create_file(user, '12', '', message: '12', branch_name: 'master')
            end

            expect(indexed_file_paths_for('12')).to include('12')
          end

          it 'reverses already indexed commits' do
            change_repository_and_index do
              repository.write_ref('master', repository.commit('HEAD~1').sha)
            end

            expect(indexed_file_paths_for('12')).not_to include('12')
          end
        end
      end
    end
  end

  context 'project repositories' do
    let(:project) { create(:project, :repository) }
    let(:repository) { project.repository }
    let(:last_commit_column) { :last_commit }
    let(:indexed_at_column) { :indexed_at }
    let(:wiki) { false }

    it_behaves_like 'repository indexer'
  end

  context 'wiki repositories' do
    let(:project) { create(:project, :wiki_repo) }
    let(:repository) { project.wiki.repository }
    let(:last_commit_column) { :last_wiki_commit }
    let(:indexed_at_column) { :wiki_indexed_at }
    let(:wiki) { true }

    it_behaves_like 'repository indexer'
  end

  def run(to_sha = nil)
    described_class.run(project, to_sha: to_sha, wiki: wiki)
  end

  def expect_popen(from_sha: Gitlab::Git::EMPTY_TREE_ID, to_sha: head_sha)
    additional_args =
      if wiki
        ['--blob-type=wiki_blob', '--skip-commits']
      else
        []
      end

    expect(Gitlab::Popen).to receive(:popen).with(
      [
        TestEnv.indexer_bin_path,
        *additional_args,
        project.id.to_s,
        "#{repository.disk_path}.git"
      ],
      nil,
      {
        'RAILS_ENV'               => Rails.env,
        'ELASTIC_CONNECTION_INFO' => elasticsearch_connection_info.to_json,
        'GITALY_CONNECTION_INFO'  => gitaly_connection_info.to_json,
        'FROM_SHA'                => from_sha,
        'TO_SHA'                  => to_sha
      }
    )
  end

  def current_index_status
    project.index_statuses.for_index(current_es_index).first
  end

  def expect_index_status(sha)
    index_status = current_index_status

    expect(index_status).not_to be_nil

    if sha
      expect(index_status[indexed_at_column]).not_to be_nil
      expect(index_status[last_commit_column]).to eq(sha)
    else
      expect(index_status[indexed_at_column]).to be_nil
      expect(index_status[last_commit_column]).to be_nil
    end
  end

  def expect_delete_index
    # We can't use expect_next_instance_of here because we're not caching
    # the proxy instances in Elastic::MultiVersionUtil.
    expect_any_instance_of(Elastic::Latest::RepositoryInstanceProxy)
      .to receive(:delete_index_for_commits_and_blobs)
      .with(wiki: wiki)
      .and_return('_shards' => { 'failed' => 0 })
  end

  def elasticsearch_connection_info
    current_es_index.connection_config.merge(
      index_name: current_es_index.name
    ).tap do |config|
      # The indexer expects the :url key, rather than the :urls key we use on the Rails side.
      config[:url] = config.delete(:urls)
    end
  end

  def gitaly_connection_info
    Gitlab::GitalyClient.connection_data(project.repository_storage).merge(
      storage: project.repository_storage
    )
  end
end
