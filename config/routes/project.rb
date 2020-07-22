# frozen_string_literal: true

constraints(::Constraints::ProjectUrlConstrainer.new) do
  # If the route has a wildcard segment, the segment has a regex constraint,
  # the segment is potentially followed by _another_ wildcard segment, and
  # the `format` option is not set to false, we need to specify that
  # regex constraint _outside_ of `constraints: {}`.
  #
  # Otherwise, Rails will overwrite the constraint with `/.+?/`,
  # which breaks some of our wildcard routes like `/blob/*id`
  # and `/tree/*id` that depend on the negative lookahead inside
  # `Gitlab::PathRegex.full_namespace_route_regex`, which helps the router
  # determine whether a certain path segment is part of `*namespace_id`,
  # `:project_id`, or `*id`.
  #
  # See https://github.com/rails/rails/blob/v4.2.8/actionpack/lib/action_dispatch/routing/mapper.rb#L155
  scope(path: '*namespace_id',
        as: :namespace,
        namespace_id: Gitlab::PathRegex.full_namespace_route_regex) do
    scope(path: ':project_id',
          constraints: { project_id: Gitlab::PathRegex.project_route_regex },
          module: :projects,
          as: :project) do
      # Begin of the /-/ scope.
      # Use this scope for all new project routes.
      scope '-' do
        get 'archive/*id', constraints: { format: Gitlab::PathRegex.archive_formats_regex, id: /.+?/ }, to: 'repositories#archive', as: 'archive'
        get 'metrics(/:dashboard_path)', constraints: { dashboard_path: /.+\.yml/ },
          to: 'metrics_dashboard#show', as: :metrics_dashboard, format: false

        resources :artifacts, only: [:index, :destroy]

        resources :packages, only: [:index, :show, :destroy], module: :packages
        resources :package_files, only: [], module: :packages do
          member do
            get :download
          end
        end

        resources :jobs, only: [:index, :show], constraints: { id: /\d+/ } do
          collection do
            resources :artifacts, only: [] do
              collection do
                get :latest_succeeded,
                  path: '*ref_name_and_path',
                  format: false
              end
            end
          end

          member do
            get :status
            post :cancel
            post :unschedule
            post :retry
            post :play
            post :erase
            get :trace, defaults: { format: 'json' }
            get :raw
            get :terminal
            get :proxy

            # These routes are also defined in gitlab-workhorse. Make sure to update accordingly.
            get '/terminal.ws/authorize', to: 'jobs#terminal_websocket_authorize', format: false
            get '/proxy.ws/authorize', to: 'jobs#proxy_websocket_authorize', format: false
          end

          resource :artifacts, only: [] do
            get :download
            get :browse, path: 'browse(/*path)', format: false
            get :file, path: 'file/*path', format: false
            get :raw, path: 'raw/*path', format: false
            post :keep
          end
        end

        namespace :ci do
          resource :lint, only: [:show, :create]
          resources :daily_build_group_report_results, only: [:index], constraints: { format: /(csv|json)/ }
        end

        namespace :settings do
          resource :ci_cd, only: [:show, :update], controller: 'ci_cd' do
            post :reset_cache
            put :reset_registration_token
            post :create_deploy_token, path: 'deploy_token/create', to: 'repository#create_deploy_token'
          end

          resource :operations, only: [:show, :update] do
            member do
              post :reset_alerting_token
              post :reset_pagerduty_token
            end
          end

          resource :integrations, only: [:show]

          resource :repository, only: [:show], controller: :repository do
            # TODO: Removed this "create_deploy_token" route after change was made in app/helpers/ci_variables_helper.rb:14
            # See MR comment for more detail: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/27059#note_311585356
            post :create_deploy_token, path: 'deploy_token/create'
            post :cleanup
          end

          resources :access_tokens, only: [:index, :create] do
            member do
              put :revoke
            end
          end
        end

        resources :autocomplete_sources, only: [] do
          collection do
            get 'members'
            get 'issues'
            get 'merge_requests'
            get 'labels'
            get 'milestones'
            get 'commands'
            get 'snippets'
          end
        end

        resources :project_members, except: [:show, :new, :edit], constraints: { id: %r{[a-zA-Z./0-9_\-#%+]+} }, concerns: :access_requestable do
          collection do
            delete :leave

            # Used for import team
            # from another project
            get :import
            post :apply_import
          end

          member do
            post :resend_invite
          end
        end

        resources :deploy_keys, constraints: { id: /\d+/ }, only: [:index, :new, :create, :edit, :update] do
          member do
            put :enable
            put :disable
          end
        end

        resources :deploy_tokens, constraints: { id: /\d+/ }, only: [] do
          member do
            put :revoke
          end
        end

        resources :milestones, constraints: { id: /\d+/ } do
          member do
            post :promote
            put :sort_issues
            put :sort_merge_requests
            get :merge_requests
            get :participants
            get :labels
          end
        end

        resources :labels, except: [:show], constraints: { id: /\d+/ } do
          collection do
            post :generate
            post :set_priorities
          end

          member do
            post :promote
            post :toggle_subscription
            delete :remove_priority
          end
        end

        resources :services, constraints: { id: %r{[^/]+} }, only: [:edit, :update] do
          member do
            put :test
          end

          resources :hook_logs, only: [:show], controller: :service_hook_logs do
            member do
              post :retry
            end
          end
        end

        resources :boards, only: [:index, :show, :create, :update, :destroy], constraints: { id: /\d+/ } do
          collection do
            get :recent
          end
        end

        resources :releases, only: [:index, :new, :show, :edit], param: :tag, constraints: { tag: %r{[^/]+} } do
          member do
            get :downloads, path: 'downloads/*filepath', format: false
            scope module: :releases do
              resources :evidences, only: [:show]
            end
          end
        end

        resources :logs, only: [:index] do
          collection do
            get :k8s
            get :elasticsearch
          end
        end

        resources :starrers, only: [:index]
        resources :forks, only: [:index, :new, :create]
        resources :group_links, only: [:create, :update, :destroy], constraints: { id: /\d+/ }

        resource :import, only: [:new, :create, :show]
        resource :avatar, only: [:show, :destroy]

        scope :grafana, as: :grafana_api do
          get 'proxy/:datasource_id/*proxy_path', to: 'grafana_api#proxy'
          get :metrics_dashboard, to: 'grafana_api#metrics_dashboard'
        end

        resource :mattermost, only: [:new, :create]
        resource :variables, only: [:show, :update]
        resources :triggers, only: [:index, :create, :edit, :update, :destroy]

        resource :mirror, only: [:show, :update] do
          member do
            get :ssh_host_keys, constraints: { format: :json }
            post :update_now
          end
        end

        resource :cycle_analytics, only: :show, path: 'value_stream_analytics'
        scope module: :cycle_analytics, as: 'cycle_analytics', path: 'value_stream_analytics' do
          scope :events, controller: 'events' do
            get :issue
            get :plan
            get :code
            get :test
            get :review
            get :staging
            get :production
          end
        end
        get '/cycle_analytics', to: redirect('%{namespace_id}/%{project_id}/-/value_stream_analytics')

        concerns :clusterable

        namespace :serverless do
          scope :functions do
            get '/:environment_id/:id', to: 'functions#show'
            get '/:environment_id/:id/metrics', to: 'functions#metrics', as: :metrics
          end

          resources :functions, only: [:index]
        end

        resources :environments, except: [:destroy] do
          member do
            post :stop
            post :cancel_auto_stop
            get :terminal
            get :metrics
            get :additional_metrics
            get :metrics_dashboard

            # This route is also defined in gitlab-workhorse. Make sure to update accordingly.
            get '/terminal.ws/authorize', to: 'environments#terminal_websocket_authorize', format: false

            get '/prometheus/api/v1/*proxy_path', to: 'environments/prometheus_api#prometheus_proxy', as: :prometheus_api

            get '/sample_metrics', to: 'environments/sample_metrics#query'
          end

          collection do
            get :metrics, action: :metrics_redirect
            get :folder, path: 'folders/*id', constraints: { format: /(html|json)/ }
            get :search
          end

          resources :deployments, only: [:index] do
            member do
              get :metrics
              get :additional_metrics
            end
          end
        end

        namespace :performance_monitoring do
          resources :dashboards, only: [:create] do
            collection do
              put '/:file_name', to: 'dashboards#update', constraints: { file_name: /.+\.yml/ }
            end
          end
        end

        resources :alert_management, only: [:index] do
          get 'details', on: :member
        end

        post 'incidents/integrations/pagerduty', to: 'incident_management/pager_duty_incidents#create'

        namespace :error_tracking do
          resources :projects, only: :index
        end

        resources :error_tracking, only: [:index], controller: :error_tracking do
          collection do
            get ':issue_id/details',
              to: 'error_tracking#details',
              as: 'details'
            get ':issue_id/stack_trace',
              to: 'error_tracking/stack_traces#index',
              as: 'stack_trace'
            put ':issue_id',
              to: 'error_tracking#update',
              as: 'update'
          end
        end

        namespace :design_management do
          namespace :designs, path: 'designs/:design_id(/:sha)', constraints: -> (params) { params[:sha].nil? || Gitlab::Git.commit_id?(params[:sha]) } do
            resource :raw_image, only: :show
            resources :resized_image, only: :show, constraints: -> (params) { DesignManagement::DESIGN_IMAGE_SIZES.include?(params[:id]) }
          end
        end

        get '/snippets/:snippet_id/raw/:ref/*path',
          to: 'snippets/blobs#raw',
          format: false,
          as: :snippet_blob_raw,
          constraints: { snippet_id: /\d+/ }

        draw :issues
        draw :merge_requests
        draw :pipelines

        # The wiki and repository routing contains wildcard characters so
        # its preferable to keep it below all other project routes
        draw :repository_scoped
        draw :repository
        draw :wiki

        namespace :import do
          resource :jira, only: [:show], controller: :jira
        end
      end
      # End of the /-/ scope.

      # All new routes should go under /-/ scope.
      # Look for scope '-' at the top of the file.

      # Serve snippet routes under /-/snippets.
      # To ensure an old unscoped routing is used for the UI we need to
      # add prefix 'as' to the scope routing and place it below original routing.
      # Issue https://gitlab.com/gitlab-org/gitlab/-/issues/29572
      scope '-', as: :scoped do
        resources :snippets, concerns: :awardable, constraints: { id: /\d+/ } do # rubocop: disable Cop/PutProjectRoutesUnderScope
          member do
            get :raw # rubocop:todo Cop/PutProjectRoutesUnderScope
            post :mark_as_spam # rubocop:todo Cop/PutProjectRoutesUnderScope
          end
        end
      end

      draw :project_unscoped

      # Deprecated unscoped routing.
      # Issue https://gitlab.com/gitlab-org/gitlab/issues/118849
      scope as: 'deprecated' do
        draw :pipelines
        draw :repository
      end

      # All new routes should go under /-/ scope.
      # Look for scope '-' at the top of the file.

      # Legacy routes.
      # Introduced in 12.0.
      # Should be removed with https://gitlab.com/gitlab-org/gitlab/issues/28848.
      Gitlab::Routing.redirect_legacy_paths(self, :mirror, :tags,
                                            :cycle_analytics, :mattermost, :variables, :triggers,
                                            :environments, :protected_environments, :error_tracking, :alert_management,
                                            :serverless, :clusters, :audit_events, :wikis, :merge_requests,
                                            :vulnerability_feedback, :security, :dependencies, :issues)
    end

    # rubocop: disable Cop/PutProjectRoutesUnderScope
    resources(:projects,
              path: '/',
              constraints: { id: Gitlab::PathRegex.project_route_regex },
              only: [:edit, :show, :update, :destroy]) do
      member do
        put :transfer
        delete :remove_fork
        post :archive
        post :unarchive
        post :housekeeping
        post :toggle_star
        post :preview_markdown
        post :export
        post :remove_export
        post :generate_new_export
        get :download_export
        get :activity
        get :refs
        put :new_issuable_address
      end
    end
    # rubocop: enable Cop/PutProjectRoutesUnderScope
  end
end
