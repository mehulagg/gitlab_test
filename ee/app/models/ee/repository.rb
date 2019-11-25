# frozen_string_literal: true

module EE
  # Repository EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `Repository` model
  module Repository
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    MIRROR_REMOTE = "upstream".freeze

    REPLICABLE_REGISTRY_CLASSES = {
      ::Gitlab::GlRepository::PROJECT    => ::Geo::ProjectRegistry,
      ::Gitlab::GlRepository::WIKI       => ::Geo::ProjectRegistry, # TODO WikiRegistry
      ::EE::Gitlab::GlRepository::DESIGN => ::Geo::DesignRegistry
    }.freeze

    prepended do
      include Elastic::RepositoriesSearch
      include ::Gitlab::Geo::Replicable::Model
      include ::Gitlab::Geo::Replicable::Strategies::Repository::Model

      delegate :checksum, :find_remote_root_ref, to: :raw_repository
      delegate :pull_mirror_branch_prefix, to: :project
    end

    def registry
      replicable_registry_class.find_by(project_id: project.id)
    end

    def replicable_registry_class
      REPLICABLE_REGISTRY_CLASSES[repo_type]
    end

    # Transiently sets a configuration variable
    def with_config(values = {})
      raw_repository.set_config(values)

      yield
    ensure
      raw_repository.delete_config(*values.keys)
    end

    # Runs code after a repository has been synced.
    def after_sync
      expire_all_method_caches
      expire_branch_cache if exists?
      expire_content_cache
    end

    def upstream_branch_name(branch_name)
      return branch_name unless ::Feature.enabled?(:pull_mirror_branch_prefix, project)
      return branch_name unless pull_mirror_branch_prefix

      # when pull_mirror_branch_prefix is set, a branch not starting with it
      # is a local branch that doesn't tracking upstream
      if branch_name.start_with?(pull_mirror_branch_prefix)
        branch_name.delete_prefix(pull_mirror_branch_prefix)
      else
        nil
      end
    end

    def fetch_upstream(url, forced: false)
      add_remote(MIRROR_REMOTE, url)
      fetch_remote(MIRROR_REMOTE, ssh_auth: project&.import_data, forced: forced)
    end

    def upstream_branches
      @upstream_branches ||= remote_branches(MIRROR_REMOTE)
    end

    def diverged_from_upstream?(branch_name)
      upstream_branch = upstream_branch_name(branch_name)
      return false unless upstream_branch

      diverged?(branch_name, MIRROR_REMOTE, upstream_branch_name: upstream_branch) do |branch_commit, upstream_commit|
        !raw_repository.ancestor?(branch_commit.id, upstream_commit.id)
      end
    end

    def upstream_has_diverged?(branch_name, remote_ref)
      diverged?(branch_name, remote_ref) do |branch_commit, upstream_commit|
        !raw_repository.ancestor?(upstream_commit.id, branch_commit.id)
      end
    end

    def up_to_date_with_upstream?(branch_name)
      upstream_branch = upstream_branch_name(branch_name)
      return false unless upstream_branch

      diverged?(branch_name, MIRROR_REMOTE, upstream_branch_name: upstream_branch) do |branch_commit, upstream_commit|
        ancestor?(branch_commit.id, upstream_commit.id)
      end
    end

    override :after_create
    def after_create
      super
    ensure
      replicable_create
    end

    override :keep_around
    def keep_around(*shas)
      super
    ensure
      log_geo_updated_event
    end

    override :after_change_head
    def after_change_head
      super
    ensure
      log_geo_updated_event
    end

    def log_geo_updated_event
      if repo_type.design?
        replicable_update
      else
        return unless ::Gitlab::Geo.primary?

        ::Geo::RepositoryUpdatedService.new(self).execute
      end
    end

    def code_owners_blob(ref: 'HEAD')
      possible_code_owner_blobs = ::Gitlab::CodeOwners::FILE_PATHS.map { |path| [ref, path] }
      blobs_at(possible_code_owner_blobs).compact.first
    end

    def insights_config_for(sha)
      blob_data_at(sha, ::Gitlab::Insights::CONFIG_FILE_PATH)
    end

    private

    def diverged?(branch_name, remote_ref, upstream_branch_name: branch_name)
      branch_commit = commit("refs/heads/#{branch_name}")
      upstream_commit = commit("refs/remotes/#{remote_ref}/#{upstream_branch_name}")

      if branch_commit && upstream_commit
        yield branch_commit, upstream_commit
      else
        false
      end
    end
  end
end
