# frozen_string_literal: true

class ProjectWiki < Wiki
  alias_method :project, :container

  # Project wikis are tied to the main project storage
  delegate :storage, :repository_storage, :hashed_storage?, to: :container

  override :find_by_id
  def self.find_by_id(id)
    return unless project = Project.find_by_id(id)

    for_container(project)
  end

  override :disk_path
  def disk_path(*args, &block)
    container.disk_path + '.wiki'
  end

  override :after_wiki_activity
  def after_wiki_activity
    # Update activity columns, this is done synchronously to avoid
    # replication delays in Geo.
    project.touch(:last_activity_at, :last_repository_updated_at)
  end

  override :after_post_receive
  def after_post_receive
    # Update storage statistics
    ProjectCacheWorker.perform_async(project.id, [], [:wiki_size])

    # This call is repeated for post-receive, to make sure we're updating
    # the activity columns for Git pushes as well.
    after_wiki_activity
  end
end

# TODO: Remove this once we implement ES support for group wikis.
# https://gitlab.com/gitlab-org/gitlab/-/issues/207889
ProjectWiki.prepend_if_ee('EE::ProjectWiki')
