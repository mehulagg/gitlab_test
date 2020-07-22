# This file contains unscoped routes.
# Please don't _add_ any new routes.
#
# New routes should be scoped to `/-/`.
#
# See https://gitlab.com/gitlab-org/gitlab/-/issues/29572

#
# Service Desk
#
get '/service_desk' => 'service_desk#show', as: :service_desk # rubocop:todo Cop/PutProjectRoutesUnderScope
put '/service_desk' => 'service_desk#update', as: :service_desk_refresh # rubocop:todo Cop/PutProjectRoutesUnderScope

#
# Templates
#
get '/templates/:template_type/:key' => 'templates#show', # rubocop:todo Cop/PutProjectRoutesUnderScope
    as: :template,
    defaults: { format: 'json' },
    constraints: { key: %r{[^/]+}, template_type: %r{issue|merge_request}, format: 'json' }

get '/description_templates/names/:template_type', # rubocop:todo Cop/PutProjectRoutesUnderScope
    to: 'templates#names',
    as: :template_names,
    defaults: { format: 'json' },
    constraints: { template_type: %r{issue|merge_request}, format: 'json' }

resource :pages, only: [:show, :update, :destroy] do # rubocop: disable Cop/PutProjectRoutesUnderScope
  resources :domains, except: :index, controller: 'pages_domains', constraints: { id: %r{[^/]+} } do # rubocop: disable Cop/PutProjectRoutesUnderScope
    member do
      post :verify # rubocop:todo Cop/PutProjectRoutesUnderScope
      post :retry_auto_ssl # rubocop:todo Cop/PutProjectRoutesUnderScope
      delete :clean_certificate # rubocop:todo Cop/PutProjectRoutesUnderScope
    end
  end
end

resources :snippets, concerns: :awardable, constraints: { id: /\d+/ } do # rubocop: disable Cop/PutProjectRoutesUnderScope
  member do
    get :raw # rubocop:todo Cop/PutProjectRoutesUnderScope
    post :mark_as_spam # rubocop:todo Cop/PutProjectRoutesUnderScope
  end
end

namespace :prometheus do
  resources :alerts, constraints: { id: /\d+/ }, only: [:index, :create, :show, :update, :destroy] do # rubocop: disable Cop/PutProjectRoutesUnderScope
    post :notify, on: :collection # rubocop:todo Cop/PutProjectRoutesUnderScope
    member do
      get :metrics_dashboard # rubocop:todo Cop/PutProjectRoutesUnderScope
    end
  end

  resources :metrics, constraints: { id: %r{[^\/]+} }, only: [:index, :new, :create, :edit, :update, :destroy] do # rubocop: disable Cop/PutProjectRoutesUnderScope
    get :active_common, on: :collection # rubocop:todo Cop/PutProjectRoutesUnderScope
    post :validate_query, on: :collection # rubocop:todo Cop/PutProjectRoutesUnderScope
  end
end

post 'alerts/notify', to: 'alerting/notifications#create' # rubocop:todo Cop/PutProjectRoutesUnderScope

draw :legacy_builds

resources :hooks, only: [:index, :create, :edit, :update, :destroy], constraints: { id: /\d+/ } do # rubocop: disable Cop/PutProjectRoutesUnderScope
  member do
    post :test # rubocop:todo Cop/PutProjectRoutesUnderScope
  end

  resources :hook_logs, only: [:show] do # rubocop: disable Cop/PutProjectRoutesUnderScope
    member do
      post :retry # rubocop:todo Cop/PutProjectRoutesUnderScope
    end
  end
end

resources :container_registry, only: [:index, :destroy, :show], # rubocop: disable Cop/PutProjectRoutesUnderScope
                               controller: 'registry/repositories'

namespace :registry do
  resources :repository, only: [] do # rubocop: disable Cop/PutProjectRoutesUnderScope
    # We default to JSON format in the controller to avoid ambiguity.
    # `latest.json` could either be a request for a tag named `latest`
    # in JSON format, or a request for tag named `latest.json`.
    scope format: false do
      resources :tags, only: [:index, :destroy], # rubocop: disable Cop/PutProjectRoutesUnderScope
                       constraints: { id: Gitlab::Regex.container_registry_tag_regex } do
        collection do
          delete :bulk_destroy # rubocop:todo Cop/PutProjectRoutesUnderScope
        end
      end
    end
  end
end

resources :notes, only: [:create, :destroy, :update], concerns: :awardable, constraints: { id: /\d+/ } do # rubocop: disable Cop/PutProjectRoutesUnderScope
  member do
    delete :delete_attachment # rubocop:todo Cop/PutProjectRoutesUnderScope
    post :resolve # rubocop:todo Cop/PutProjectRoutesUnderScope
    delete :resolve, action: :unresolve # rubocop:todo Cop/PutProjectRoutesUnderScope
  end
end

get 'noteable/:target_type/:target_id/notes' => 'notes#index', as: 'noteable_notes' # rubocop:todo Cop/PutProjectRoutesUnderScope

resources :todos, only: [:create] # rubocop: disable Cop/PutProjectRoutesUnderScope

resources :uploads, only: [:create] do # rubocop: disable Cop/PutProjectRoutesUnderScope
  collection do
    get ":secret/:filename", action: :show, as: :show, constraints: { filename: %r{[^/]+} }, format: false, defaults: { format: nil } # rubocop:todo Cop/PutProjectRoutesUnderScope
    post :authorize # rubocop:todo Cop/PutProjectRoutesUnderScope
  end
end

resources :runners, only: [:index, :edit, :update, :destroy, :show] do # rubocop: disable Cop/PutProjectRoutesUnderScope
  member do
    post :resume # rubocop:todo Cop/PutProjectRoutesUnderScope
    post :pause # rubocop:todo Cop/PutProjectRoutesUnderScope
  end

  collection do
    post :toggle_shared_runners # rubocop:todo Cop/PutProjectRoutesUnderScope
    post :toggle_group_runners # rubocop:todo Cop/PutProjectRoutesUnderScope
  end
end

resources :runner_projects, only: [:create, :destroy] # rubocop: disable Cop/PutProjectRoutesUnderScope
resources :badges, only: [:index] do # rubocop: disable Cop/PutProjectRoutesUnderScope
  collection do
    scope '*ref', constraints: { ref: Gitlab::PathRegex.git_reference_regex } do
      constraints format: /svg/ do
        get :pipeline # rubocop:todo Cop/PutProjectRoutesUnderScope
        get :coverage # rubocop:todo Cop/PutProjectRoutesUnderScope
      end
    end
  end
end

scope :usage_ping, controller: :usage_ping do
  post :web_ide_clientside_preview # rubocop:todo Cop/PutProjectRoutesUnderScope
  post :web_ide_pipelines_count # rubocop:todo Cop/PutProjectRoutesUnderScope
end

resources :web_ide_terminals, path: :ide_terminals, only: [:create, :show], constraints: { id: /\d+/, format: :json } do # rubocop: disable Cop/PutProjectRoutesUnderScope
  member do
    post :cancel # rubocop:todo Cop/PutProjectRoutesUnderScope
    post :retry # rubocop:todo Cop/PutProjectRoutesUnderScope
  end

  collection do
    post :check_config # rubocop:todo Cop/PutProjectRoutesUnderScope
  end
end

