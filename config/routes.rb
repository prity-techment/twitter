Rails.application.routes.draw do
  mount API::Base => '/api'
  mount GrapeSwaggerRails::Engine => '/swagger'
  get 'users/:user_id/show', to: 'users#follow', as: 'show_user'
  get 'users/:user_id/follow', to: 'users#follow', as: 'follow'

  root 'tweets#index'
  resources :tweets
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
