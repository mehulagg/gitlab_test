# frozen_string_literal: true

module Repositories
  class GitHttpController < Repositories::GitHttpClientController
    include WorkhorseRequest

    before_action :access_check
    prepend_before_action :deny_head_requests, only: [:info_refs]

    rescue_from Gitlab::GitAccess::ForbiddenError, with: :render_403_with_exception
    rescue_from Gitlab::GitAccess::NotFoundError, with: :render_404_with_exception
    rescue_from Gitlab::GitAccess::ProjectCreationError, with: :render_422_with_exception
    rescue_from Gitlab::GitAccess::TimeoutError, with: :render_503_with_exception

    before_action :snippet_request_allowed?

    # GET /foo/bar.git/info/refs?service=git-upload-pack (git pull)
    # GET /foo/bar.git/info/refs?service=git-receive-pack (git push)
    def info_refs
      log_user_activity if upload_pack?

      render_ok
    end

    # POST /foo/bar.git/git-upload-pack (git pull)
    def git_upload_pack
      enqueue_fetch_statistics_update

      render_ok
    end

    # POST /foo/bar.git/git-receive-pack" (git push)
    def git_receive_pack
      render_ok
    end

    private

    def deny_head_requests
      head :forbidden if request.head?
    end

    def download_request?
      upload_pack?
    end

    def upload_pack?
      git_command == 'git-upload-pack'
    end

    def git_command
      if action_name == 'info_refs'
        params[:service]
      else
        action_name.dasherize
      end
    end

    def render_ok
      set_workhorse_internal_api_content_type
      render json: Gitlab::Workhorse.git_http_ok(repository, repo_type, user, action_name)
    end

    def render_403_with_exception(exception)
      render plain: exception.message, status: :forbidden
    end

    def render_404_with_exception(exception)
      render plain: exception.message, status: :not_found
    end

    def render_422_with_exception(exception)
      render plain: exception.message, status: :unprocessable_entity
    end

    def render_503_with_exception(exception)
      render plain: exception.message, status: :service_unavailable
    end

    def enqueue_fetch_statistics_update
      return if Gitlab::Database.read_only?
      return unless repo_type.project?
      return unless project&.daily_statistics_enabled?

      ProjectDailyStatisticsWorker.perform_async(project.id) # rubocop:disable CodeReuse/Worker
    end

    def access
      @access ||= access_klass.new(access_actor, container, 'http',
        authentication_abilities: authentication_abilities,
        namespace_path: params[:namespace_id],
        repository_path: repository_path,
        redirected_path: redirected_path,
        auth_result_type: auth_result_type)
    end

    def access_actor
      return user if user
      return :ci if ci?
    end

    def access_check
      access.check(git_command, Gitlab::GitAccess::ANY)

      if repo_type.project? && !container
        @project = @container = access.project
      end
    end

    def access_klass
      @access_klass ||= repo_type.access_checker_class
    end

    def repository_path
      @repository_path ||= params[:repository_id].sub(/\.git$/, '')
    end

    def log_user_activity
      Users::ActivityService.new(user).execute
    end

    def snippet_request_allowed?
      return unless repo_type.snippet?

      unless Feature.enabled?(:version_snippets, user)
        render plain: 'The project you were looking for could not be found.', status: :not_found
      end
    end
  end
end

Repositories::GitHttpController.prepend_if_ee('EE::Repositories::GitHttpController')
