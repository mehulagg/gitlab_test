# frozen_string_literal: true

module Geo
  # Reflect a repository storage relocation on a secondary node
  class MoveRepositoryStorageService
    include Gitlab::ShellAdapter

    REPO_REMOVAL_DELAY = 5.minutes

    attr_reader :project_id, :old_repository_storage, :new_repository_storage

    def initialize(project_id, old_repository_storage, new_repository_storage)
      @project_id = project_id
      @old_repository_storage = old_repository_storage
      @new_repository_storage = new_repository_storage
    end

    def async_execute
      Geo::MoveRepositoryStorageWorker.perform_async(project_id, old_repository_storage, new_repository_storage)
    end

    def execute
      return unless Gitlab::Geo.secondary?

      move_repository
    end

    private

    def project
      @project ||= Project.find(project_id)
    end

    def move_repository
      result = true

      unless project.repository_exists?
        result &&= mirror_repository(type: Gitlab::GlRepository::PROJECT)
      end

      unless project.wiki.repository_exists?
        result &&= mirror_repository(type: Gitlab::GlRepository::WIKI)
      end

      unless project.design_repository.exists?
        result &&= mirror_repository(type: Gitlab::GlRepository::DESIGN)
      end

      if result
        delete_repository(storage, type: Gitlab::GlRepository::PROJECT)
        delete_repository(storage, type: Gitlab::GlRepository::WIKI)
        delete_repository(storage, type: Gitlab::GlRepository::DESIGN)

        enqueue_housekeeping
      end
    end

    def mirror_repository(type:)
      repository = type.repository_for(project)
      disk_path = repository.disk_path
      raw_repository = repository.raw

      # Initialize a git repository on the target path
      gitlab_shell.create_repository(new_repository_storage, raw_repository.relative_path, disk_path)
      new_repository = Gitlab::Git::Repository.new(new_repository_storage,
                                                   raw_repository.relative_path,
                                                   raw_repository.gl_repository,
                                                   full_path)

      new_repository.fetch_repository_as_mirror(raw_repository)
    end

    # The underlying FetchInternalRemote call uses a `git fetch` to move data
    # to the new repository, which leaves it in a less-well-packed state,
    # lacking bitmaps and commit graphs. Housekeeping will boost performance
    # significantly.
    def enqueue_housekeeping
      return unless Gitlab::CurrentSettings.housekeeping_enabled?
      return unless Feature.enabled?(:repack_after_shard_migration, project)

      Projects::HousekeepingService.new(project, :gc).execute
    rescue Projects::HousekeepingService::LeaseTaken
      # No action required
    end

    def delete_repository(storage, type: Gitlab::GlRepository::PROJECT)
      repository = type.repository_for(project)
      disk_path = repository.disk_path

      return unless repo_exists?(disk_path)

      log_info(%Q{Repository "#{disk_path}" scheduled for removal in storage "#{storage}" for project "#{project.full_path}"})

      GitlabShellWorker.perform_in(REPO_REMOVAL_DELAY, :remove_repository, storage, disk_path)
    end

    def repo_exists?(disk_path)
      gitlab_shell.repository_exists?(project.repository_storage, disk_path + '.git')
    end
  end
end
