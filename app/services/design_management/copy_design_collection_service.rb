# frozen_string_literal: true

# This service copies a design collection's designs, version history,
# and design discussions, from one issue to another.
module DesignManagement
  class CopyDesignCollectionService < DesignService
    # rubocop: disable CodeReuse/ActiveRecord
    def initialize(project, user, params = {})
      super

      @target_issue = params.fetch(:target_issue)
      @target_project = @target_issue.project
      @target_repository = @target_project.design_repository
      @target_design_collection = @target_issue.design_collection

      @designs = DesignManagement::Design.unscoped.where(issue: issue).order(:id).to_a
      @versions = DesignManagement::Version.unscoped.where(issue: issue).order(:id).to_a
      @blobs = fetch_blobs

      @sha_attribute = Gitlab::Database::ShaAttribute.new
      @shas = []
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def execute
      return error('User cannot copy design collection to issue') unless user_can_copy?
      return error('Design collection has no designs') if design_collection.empty?
      return error('Target design collection already has designs') unless target_design_collection.empty?

      ActiveRecord::Base.transaction do
        # PostgreSQL data
        new_design_ids = copy_designs!
        new_version_ids = copy_versions!
        copy_actions!(new_design_ids, new_version_ids)
        copy_notes!
        link_lfs_files!
        # Git data
        copy_commits!(new_version_ids)
      end

      ServiceResponse.success
    rescue => error
      log_error(error)

      rollback_commits!

      error('Designs were unable to be copied successfully')
    end

    private

    attr_reader :blobs, :designs, :sha_attribute, :shas, :target_design_collection,
                :target_issue, :target_repository, :target_project, :versions

    def log_error(error)
      Gitlab::ErrorTracking.track_exception(error, {
        issue_id: issue.id, project_id: project.id, target_issue_id: target_issue.id, target_project: target_project.id
      })
    end

    def error(message)
      target_design_collection.error_copy!
      ServiceResponse.error(message: message)
    end

    def user_can_copy?
      current_user.can?(:read_design, design_collection) &&
        current_user.can?(:admin_issue, target_issue)
    end

    def copy_designs!
      design_attributes = attributes_config[:design_attributes]

      new_rows = designs.map do |design|
        design.attributes.slice(*design_attributes).merge(
          issue_id: target_issue.id,
          project_id: target_project.id
        )
      end

      ::Gitlab::Database.bulk_insert(
        DesignManagement::Design.table_name,
        new_rows,
        return_ids: true
      )
    end

    def copy_versions!
      version_attributes = attributes_config[:version_attributes]

      new_rows = versions.map do |version|
        version.attributes.slice(*version_attributes).merge(
          issue_id: target_issue.id,
          sha: sha_attribute.serialize(version.sha)
        )
      end

      ::Gitlab::Database.bulk_insert(
        DesignManagement::Version.table_name,
        new_rows,
        return_ids: true
      )
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def copy_actions!(new_design_ids, new_version_ids)
      # Create a map of <Old design id> => <New design id>
      design_id_map = new_design_ids.each_with_index.each_with_object({}) do |design_id_and_index, hash|
        design_id, i = design_id_and_index
        hash[designs[i].id] = design_id
      end

      # Create a map of <Old version id> => <New version id>
      version_id_map = new_version_ids.each_with_index.each_with_object({}) do |version_id_and_index, hash|
        version_id, i = version_id_and_index
        hash[versions[i].id] = version_id
      end

      actions = DesignManagement::Action.unscoped.select(:design_id, :version_id, :event).where(design: designs, version: versions)
      new_rows = actions.map do |action|
        {
          design_id: design_id_map[action.design_id],
          version_id: version_id_map[action.version_id],
          event: action.event_before_type_cast
        }
      end

      ::Gitlab::Database.bulk_insert(
        DesignManagement::Action.table_name,
        new_rows
      )
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # rubocop: disable CodeReuse/ActiveRecord
    def link_lfs_files!
      oids = blobs.map(&:lfs_oid)

      LfsObject.where(oid: oids).find_each(batch_size: 100) do |lfs_object|
        LfsObjectsProject.safe_find_or_create_by!(
          project: target_project,
          lfs_object: lfs_object,
          repository_type: :design
        )
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # rubocop: disable CodeReuse/ActiveRecord
    def copy_commits!(new_version_ids)
      target_repository.create_if_not_exists

      # { 0 => :create, 1 => :update, 2 => :delete}
      event_enum_raw = DesignManagement::DesignAction::EVENT_FOR_GITALY_ACTION.invert

      target_issue.design_versions.includes(actions: :design).find_each(batch_size: 100) do |version|
        # blob.data is content of the LfsPointer file and not the
        # content, and can be nil for deletions
        content = blobs.find { |b| b.commit_id == version.sha }&.data

        gitaly_actions = version.actions.map do |action|
          DesignManagement::DesignAction.new(
            action.design,
            event_enum_raw[action.event_before_type_cast],
            content
          )
        end

        sha = target_repository.multi_action(
          current_user,
          branch_name: target_branch,
          message: commit_message(version),
          actions: gitaly_actions.map(&:gitaly_action)
        )

        shas << sha

        # Update the version sha to reflect the git commit
        version.update_column(:sha, sha)
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def copy_notes!
      new_designs = target_issue.designs.to_a

      # Todo filter only designs with notes?
      designs.each do |old_design|
        new_design = new_designs.find { |d| d.filename == old_design.filename }

        next unless new_design

        Notes::CopyService.new(current_user, old_design, new_design).execute
      end
    end

    # We need to fetch blob data in order to find the oids for LfsObjects
    # and also to save Gitaly Data.
    # Blobs are reasonably small in memory, as their data are LFS Pointer files
    def fetch_blobs
      items = versions.inject([]) do |memo, version|
        memo += version.designs.map { |d| [version.sha, d.full_path] }
      end

      repository.blobs_at(items)
    end

    def commit_message(version)
      "Copy commit #{version.sha} from issue #{issue.to_reference(full: true)}"
    end

    def attributes_config
      @attributes_config ||= YAML.load_file(attributes_config_file).symbolize_keys
    end

    def attributes_config_file
      Rails.root.join('lib/gitlab/design_management/copy_design_collection_model_attributes.yml')
    end

    def target_branch
      target_repository.root_ref || 'master'
    end

    def rollback_commits!
      return if shas.empty?

      commits = target_repository.commits_by(oids: shas)
      commits.each(&method(:revert_commit!))
    end

    def revert_commit!(commit)
      target_repository.raw.revert(
        user: current_user,
        commit: commit,
        branch_name: target_branch,
        message: commit.revert_message(current_user),
        start_branch_name: target_branch,
        start_repository: target_repository.raw
      )
    rescue Gitlab::Git::Repository::CreateTreeError,
           Gitlab::Git::CommitError,
           Gitlab::Git::PreReceiveError => e
      log_error(e)
    end
  end
end
