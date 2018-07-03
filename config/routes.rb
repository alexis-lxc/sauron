require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  devise_for :user,only: :sessions

  root to: 'container_hosts#index'
  get '/ping', to: 'health_check#ping'

  post '/container-hosts', to: 'container_hosts#create', as: 'container_hosts_create'
  get '/container-hosts', to: 'container_hosts#index', as: 'container_hosts'
  get '/container-hosts/:id', to: 'container_hosts#show', as: 'container_host'

  post '/containers', to: 'containers#create', as: 'containers_create'
  get '/containers', to: 'containers#index', as: 'containers'
  get '/container', to: 'containers#show', as: 'container'
  get '/containers/new', to: 'containers#new', as: 'containers_new'
  delete '/containers', to: 'containers#destroy', as: 'container_delete'

  resources :key_pairs, except: [:edit, :update]

  post '/profiles', to: 'profiles#create', as: 'profiles_create'
  get '/profiles', to: 'profiles#index', as: 'profiles'
  get '/profile/:name', to: 'profiles#show', as: 'profile'
end
