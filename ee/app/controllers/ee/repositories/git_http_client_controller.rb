# frozen_string_literal: true

module EE
  module Repositories
    module GitHttpClientController
      extend ActiveSupport::Concern

      # This module is responsible for determining if an incoming Geo secondary
      # bound HTTP request should be redirected to the Primary.
      #
      # Why?  A secondary is not allowed to perform any write actions, so any
      # request of this type need to be sent through to the Primary.  By
      # redirecting within code, we allow clients to git pull/push using their
      # secondary git remote without needing an additional primary remote.
      #
      # The method for redirection *must* happen as early as possible in the
      # request.  For example, putting the redirection logic in #access_check
      # will not work because the git client will not accept a 302 in response
      # to verifying credentials.
      #
      # Current secondary HTTP requests to redirect: -
      #
      # * git push
      #   * GET   /repo.git/info/refs?service=git-receive-pack
      #   * POST  /repo.git/git-receive-pack
      #
      # * git lfs push (usually happens automatically as part of a `git push`)
      #   * POST  /repo.git/info/lfs/objects/batch (and we examine
      #     params[:operation] to ensure we're dealing with an upload request)
      #
      # For more detail, see the following links:
      #
      # git: https://git-scm.com/book/en/v2/Git-Internals-Transfer-Protocols
      # git-lfs: https://github.com/git-lfs/git-lfs/blob/master/docs/api
      #
      prepended do
        prepend_before_action do
          redirect_to(geo_primary_full_url) if geo_redirect?
        end
      end

      private

      class GeoRouteHelper
        attr_reader :controller_name, :action_name

        CONTROLLER_AND_ACTIONS_TO_REDIRECT = {
          'git_http' => %w{git_receive_pack},
          'lfs_locks_api' => %w{create unlock verify}
        }.freeze

        def initialize(project, controller_name, action_name, service)
          @project = project
          @controller_name = controller_name
          @action_name = action_name
          @service = service
        end

        def match?(c_name, a_name)
          controller_name == c_name && action_name == a_name
        end

        def redirect?
          !!CONTROLLER_AND_ACTIONS_TO_REDIRECT[controller_name]&.include?(action_name) ||
            git_receive_pack_request?
        end

        private

        attr_reader :project, :service

        # Examples:
        #
        # /repo.git/info/refs?service=git-receive-pack returns 'git-receive-pack'
        # /repo.git/info/refs?service=git-upload-pack returns 'git-upload-pack'
        # /repo.git/git-receive-pack returns 'git-receive-pack'
        # /repo.git/git-upload-pack returns 'git-upload-pack'
        #
        def service_or_action_name
          info_refs_request? ? service : action_name.dasherize
        end

        # Matches:
        #
        # GET  /repo.git/info/refs?service=git-receive-pack
        # POST /repo.git/git-receive-pack
        #
        def git_receive_pack_request?
          service_or_action_name == 'git-receive-pack'
        end

        # Matches:
        #
        # GET /repo.git/info/refs?service=git-upload-pack
        #
        def git_upload_pack_request?
          info_refs_request? && service_or_action_name == 'git-upload-pack'
        end

        # Matches:
        #
        # GET /repo.git/info/refs
        #
        def info_refs_request?
          action_name == 'info_refs'
        end
      end

      class GeoGitLFSHelper
        MINIMUM_GIT_LFS_VERSION = '2.4.2'.freeze

        def initialize(geo_route_helper, operation, current_version)
          @geo_route_helper = geo_route_helper
          @operation = operation
          @current_version = current_version
        end

        def incorrect_version_response
          {
            json: { message: incorrect_version_message },
            content_type: ::LfsRequest::CONTENT_TYPE,
            status: 403
          }
        end

        def redirect?
          return false unless geo_route_helper.match?('lfs_api', 'batch')
          return true if upload?

          false
        end

        def version_ok?
          return false unless current_version

          ::Gitlab::VersionInfo.parse(current_version) >= wanted_version
        end

        private

        attr_reader :geo_route_helper, :operation, :current_version

        def incorrect_version_message
          translation = _("You need git-lfs version %{min_git_lfs_version} (or greater) to continue. Please visit https://git-lfs.github.com")
          translation % { min_git_lfs_version: MINIMUM_GIT_LFS_VERSION }
        end

        def upload?
          operation == 'upload'
        end

        def wanted_version
          ::Gitlab::VersionInfo.parse(MINIMUM_GIT_LFS_VERSION)
        end
      end

      def geo_route_helper
        @geo_route_helper ||= GeoRouteHelper.new(project, controller_name, action_name, params[:service])
      end

      def geo_git_lfs_helper
        # params[:operation] explained: https://github.com/git-lfs/git-lfs/blob/master/docs/api/batch.md#requests
        @geo_git_lfs_helper ||= GeoGitLFSHelper.new(geo_route_helper, params[:operation], request.headers['User-Agent'])
      end

      def geo_request_fullpath_for_primary
        relative_url_root = ::Gitlab.config.gitlab.relative_url_root.chomp('/')
        request.fullpath.sub(relative_url_root, '')
      end

      def geo_primary_full_url
        path = if geo_route_helper.geo_selective_sync_redirect?
                 # git clone/pull
                 geo_request_fullpath_for_primary
               else
                 # git push
                 File.join(geo_secondary_referrer_path_prefix, geo_request_fullpath_for_primary)
               end

        ::Gitlab::Utils.append_path(::Gitlab::Geo.primary_node.internal_url, path)
      end

      def geo_secondary_referrer_path_prefix
        File.join(::Gitlab::Geo::GitPushHttp::PATH_PREFIX, ::Gitlab::Geo.current_node.id.to_s)
      end

      def geo_redirect?
        # Don't redirect if we're not a secondary with a primary
        return false unless ::Gitlab::Geo.secondary_with_primary?

        # Redirect as the request matches GeoRouteHelper::CONTROLLER_AND_ACTIONS_TO_REDIRECT
        return true if geo_route_helper.redirect?

        # Look to redirect, as we're an LFS batch upload request
        if geo_git_lfs_helper.redirect?
          # Redirect as git-lfs version is at least 2.4.2
          return true if geo_git_lfs_helper.version_ok?

          # git-lfs 2.4.2 is really only required for requests that involve
          # redirection, so we only render if it's an LFS upload operation
          #
          render(geo_git_lfs_helper.incorrect_version_response)

          # Don't redirect
          return false
        end

        # Don't redirect
        false
      end
    end
  end
end
