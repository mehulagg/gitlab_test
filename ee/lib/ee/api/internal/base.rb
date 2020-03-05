# frozen_string_literal: true

module EE
  module API
    module Internal
      module Base
        extend ActiveSupport::Concern

        prepended do
          helpers do
            include ::Gitlab::Utils::StrongMemoize
            extend ::Gitlab::Utils::Override

            override :lfs_authentication_url
            def lfs_authentication_url(project)
              project.lfs_http_url_to_repo(params[:operation])
            end

            override :ee_post_receive_response_hook
            def ee_post_receive_response_hook(response)
              response.add_basic_message(geo_selective_sync_message) if geo_display_selective_sync_message?
              response.add_basic_message(geo_secondary_lag_message) if geo_display_secondary_lag_message?
            end

            def geo_display_secondary_lag_message?
              ::Gitlab::Geo.primary? && geo_current_replication_lag.to_i > 0
            end

            def geo_secondary_lag_message
              "Current replication lag: #{geo_current_replication_lag} seconds"
            end

            def geo_display_selective_sync_message?
              ::Gitlab::Geo.primary? &&
                geo_referred_node&.selective_sync? &&
                !geo_referred_node&.projects_include?(project.id)
            end

            def geo_selective_sync_message
              project_path = project.full_path
              geo_project_secondary_url = "#{geo_referred_node.url.chomp('/')}/#{project_path}"
              geo_project_primary_url = "#{geo_current_node.url.chomp('/')}/#{project_path}"

              <<~EOS
              You attempted to access:

              #{geo_project_secondary_url}

              but this project is currently not selected for replication. You are being
              redirected to the primary:

              #{geo_project_primary_url}

              Please contact your systems administrator to ensure all relevant projects are
              replicated to your closest Geo secondary.
              EOS
            end

            def geo_current_node
              ::Gitlab::Geo.current_node
            end

            def geo_current_replication_lag
              strong_memoize(:geo_current_replication_lag) do
                geo_referred_node&.status&.db_replication_lag_seconds
              end
            end

            def geo_referred_node
              strong_memoize(:geo_referred_node) do
                ::Gitlab::Geo::GitPushHttp.new(params[:identifier], params[:gl_repository]).fetch_referrer_node
              end
            end

            override :check_allowed
            def check_allowed(params)
              ip = params.fetch(:check_ip, nil)
              ::Gitlab::IpAddressState.with(ip) do # rubocop: disable CodeReuse/ActiveRecord
                super
              end
            end
          end
        end
      end
    end
  end
end
