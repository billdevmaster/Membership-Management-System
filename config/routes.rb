Rails.application.routes.draw do
  get 'cube/index'
  root 'public_pages#welcome'
  # temp home page while building
  get '/welcome_home', to: 'public_pages#welcome_home'
  get '/space_home', to: 'public_pages#space_home'
  get '/signup',  to: 'public_pages#signup'
  post '/signup',  to: 'public_pages#create_account'
  get '/purchases/clear_filters', to: 'admin/purchases#clear_filters', as: 'clear_purchase_filters'
  get '/clients/clear_filters', to: 'admin/clients#clear_filters', as: 'clear_client_filters'
  # note (check this is true) if the 'get' is not before the 'resources', the get purchases/search will be handled by the show method (with params[:id] = 'search')
  get '/purchases/filter', to: 'admin/purchases#filter', as: 'purchase_filter'
  get '/wkclasses/filter', to: 'admin/wkclasses#filter', as: 'wkclass_filter'
  get '/clients/filter', to: 'admin/clients#filter', as: 'client_filter'
  get '/superadmin/expenses/filter', to: 'superadmin/expenses#filter'
  get '/products/payment', to: 'admin/products#payment'
  get    '/login',   to: 'auth/sessions#new'
  post   '/login',   to: 'auth/sessions#create'
  delete '/logout',  to: 'auth/sessions#destroy'
  get    'client/clients/:id/book',   to: 'client/clients#book', as: 'client_book'
  get    'client/clients/:id/history',   to: 'client/clients#history', as: 'client_history'
  get    'client/clients/:id/buy',   to: 'client/clients#buy', as: 'client_buy'
  get '/client/timetable', to: 'client/clients#timetable', as: 'client_timetable' 
  get '/footfall', to: 'admin/attendances#footfall'
  get '/timetable', to: 'admin/timetables#show_public'


  namespace :admin do
    resources :entries, only: [:new, :edit, :create, :update, :destroy]
    resources :table_times, only: [:new, :edit, :create, :update, :destroy]
    resources :table_days, only: [:new, :edit, :create, :update, :destroy]
    resources :timetables
    resources :accounts, only: [:create, :update]
    resources :adjustments, only: [:new, :edit, :create, :update, :destroy]
    resources :attendances, only: [:index, :new, :create, :update, :destroy]
    resources :clients
    resources :fitternities
    resources :freezes, only: [:new, :edit, :create, :update, :destroy]
    resources :instructors, only: [:index, :new, :edit, :create, :update, :destroy]
    resources :partners
    resources :prices, only: [:new, :edit, :create, :update, :destroy]
    resources :products
    resources :purchases
    resources :wkclasses
    resources :workouts, only: [:index, :new, :edit, :create, :update, :destroy]
    resources :workout_groups
  end
  namespace :superadmin do
    resources :expenses, only: [:index, :new, :edit, :create, :update, :destroy]
    resources :instructor_rates, only: [:index, :new, :edit, :create, :update, :destroy]
    resource :settings
    resources :orders
    get "refund/:id", to: "orders#refund" 
  end
  # get 'client/clients/:id', to: 'client/clients#show', as: 'client_show'
  namespace :client do
    resources :clients, only: [:show]
  end

  get 'shop/index'
  get 'shop/sell'
  get 'shop/wedontsupport'

end
