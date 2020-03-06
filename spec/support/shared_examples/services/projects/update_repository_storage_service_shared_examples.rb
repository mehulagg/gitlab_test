# frozen_string_literal: true

RSpec.shared_examples 'moves repository to another storage' do |repository_type|
  let(:project_repository_double) { double(:repository) }
  let(:repository_double) { double(:repository) }

  before do
    # Default stub for non-specified params
    allow(Gitlab::Git::Repository).to receive(:new).and_call_original

    allow(Gitlab::Git::Repository).to receive(:new)
      .with('test_second_storage', project.repository.raw.relative_path, project.repository.gl_repository, project.repository.full_path)
      .and_return(project_repository_double)

    allow(Gitlab::Git::Repository).to receive(:new)
      .with('test_second_storage', repository.raw.relative_path, repository.gl_repository, repository.full_path)
      .and_return(repository_double)
  end

  context 'when the move succeeds', :clean_gitlab_redis_shared_state do
    before do
      allow(project_repository_double)
        .to receive(:replicate)
        .with(project.repository.raw)
        .and_return(true)

      allow(repository_double)
        .to receive(:replicate)
        .with(repository.raw)
        .and_return(true)
    end

    it "moves the project and its #{repository_type} repository to the new storage and unmarks the repository as read only" do
      old_project_repository_path = Gitlab::GitalyClient::StorageSettings.allow_disk_access do
        project.repository.path_to_repo
      end

      old_repository_path = repository.full_path

      subject.execute('test_second_storage')

      expect(project).not_to be_repository_read_only
      expect(project.repository_storage).to eq('test_second_storage')
      expect(gitlab_shell.repository_exists?('default', old_project_repository_path)).to be(false)
      expect(gitlab_shell.repository_exists?('default', old_repository_path)).to be(false)
    end

    context ':repack_after_shard_migration feature flag disabled' do
      before do
        stub_feature_flags(repack_after_shard_migration: false)
      end

      it 'does not enqueue a GC run' do
        expect { subject.execute('test_second_storage') }
          .not_to change(GitGarbageCollectWorker.jobs, :count)
      end
    end

    context ':repack_after_shard_migration feature flag enabled' do
      before do
        stub_feature_flags(repack_after_shard_migration: true)
      end

      it 'does not enqueue a GC run if housekeeping is disabled' do
        stub_application_setting(housekeeping_enabled: false)

        expect { subject.execute('test_second_storage') }
          .not_to change(GitGarbageCollectWorker.jobs, :count)
      end

      it 'enqueues a GC run' do
        expect { subject.execute('test_second_storage') }
          .to change(GitGarbageCollectWorker.jobs, :count).by(1)
      end
    end
  end

  context 'when the project is already on the target storage' do
    it 'bails out and does nothing' do
      expect do
        subject.execute(project.repository_storage)
      end.to raise_error(described_class::RepositoryAlreadyMoved)
    end
  end

  context "when the move of the #{repository_type} repository fails" do
    it 'unmarks the repository as read-only without updating the repository storage' do
      allow(project_repository_double).to receive(:replicate)
        .with(project.repository.raw).and_return(true)
      allow(repository_double).to receive(:replicate)
        .with(repository.raw).and_return(false)

      expect(GitlabShellWorker).not_to receive(:perform_async)

      subject.execute('test_second_storage')

      expect(project).not_to be_repository_read_only
      expect(project.repository_storage).to eq('default')
    end
  end
end
