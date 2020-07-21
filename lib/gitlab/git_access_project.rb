# frozen_string_literal: true

module Gitlab
  class GitAccessProject < GitAccess
    extend ::Gitlab::Utils::Override

    CreationError = Class.new(StandardError)

    ERROR_MESSAGES = {
      namespace_not_found: 'The namespace you were looking for could not be found.'
    }.freeze

    override :download_ability
    def download_ability
      :download_code
    end

    override :push_ability
    def push_ability
      :push_code
    end

    private

    override :check_push_access!
    def check_push_access!
      super

      check_change_access!
    end

    def check_change_access!
      # Deploy keys with write access can push anything
      return if deploy_key?

      if changes == ANY
        can_push = user_can_push? ||
          project&.any_branch_allows_collaboration?(user_access.user)

        unless can_push
          raise ForbiddenError, ERROR_MESSAGES[:push_code]
        end
      else
        # If there are worktrees with a HEAD pointing to a non-existent object,
        # calls to `git rev-list --all` will fail in git 2.15+. This should also
        # clear stale lock files.
        project.repository.clean_stale_repository_files

        # Iterate over all changes to find if user allowed all of them to be applied
        changes_list.each.with_index do |change, index|
          first_change = index == 0

          # If user does not have access to make at least one change, cancel all
          # push by allowing the exception to bubble up
          check_single_change_access(change, skip_lfs_integrity_check: !first_change)
        end
      end
    end

    def check_single_change_access(change, skip_lfs_integrity_check: false)
      Checks::ChangeAccess.new(
        change,
        user_access: user_access,
        project: project,
        skip_lfs_integrity_check: skip_lfs_integrity_check,
        protocol: protocol,
        logger: logger
      ).validate!
    rescue Checks::TimedLogger::TimeoutError
      raise TimeoutError, logger.full_message
    end

    override :check_container!
    def check_container!
      check_namespace!
      ensure_project_on_push!

      super
    end

    def check_namespace!
      raise NotFoundError, ERROR_MESSAGES[:namespace_not_found] unless namespace_path.present?
    end

    def namespace
      @namespace ||= Namespace.find_by_full_path(namespace_path)
    end

    def ensure_project_on_push!
      return if project || deploy_key?
      return unless receive_pack? && changes == ANY && authentication_abilities.include?(:push_code)
      return unless user&.can?(:create_projects, namespace)

      project_params = {
        path: repository_path,
        namespace_id: namespace.id,
        visibility_level: Gitlab::VisibilityLevel::PRIVATE
      }

      project = Projects::CreateService.new(user, project_params).execute

      unless project.saved?
        raise CreationError, "Could not create project: #{project.errors.full_messages.join(', ')}"
      end

      self.container = project
      user_access.container = project

      Checks::ProjectCreated.new(repository, user, protocol).add_message
    end
  end
end
