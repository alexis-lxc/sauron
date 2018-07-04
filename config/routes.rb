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
  get '/profiles/new', to: 'profiles#new', as: 'profile_new'
  get '/profiles/:name/edit', to: 'profiles#edit', as: 'profile_edit'
  #this route will conflict with get show, when :name is 'new'. i.e. someone making a get call on profile named 'new'
  get '/profiles/:name', to: 'profiles#show', as: 'profile'
  patch '/profiles/:name', to: 'profiles#update', as: 'profile_update'
end
