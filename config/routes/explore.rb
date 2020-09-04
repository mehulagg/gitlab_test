namespace :explore do
  resources :projects, controller: :lab_projects, only: [:index] do
    collection do
      get :trending
      get :starred
    end
  end

  resources :groups, only: [:index]
  resources :snippets, only: [:index]
  root to: 'projects#index'
end

# Compatibility with old routing
get 'public' => 'explore/lab_projects#index'
get 'public/projects' => 'explore/lab_projects#index'
