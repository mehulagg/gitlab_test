# frozen_string_literal: true

resources :trials, only: [:new, :create] do
  collection do
    get :company_info
    get :select_namespace
  end
end
