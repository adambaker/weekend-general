WeekendGeneral::Application.routes.draw do

  resources :events do
    resources :links, only: [:create, :update, :destroy]
    resources :rsvps, only: [:create, :destroy]
    
    #rsvp aliases
    resources :hosts, controller: :rsvps, kind: 'host', 
      only: [:create, :destroy]
    resources :maybes, controller: :rsvps, kind: 'maybe', 
      only: [:create, :destroy]
    resources :attendees, controller: :rsvps, kind: 'attend', 
      only: [:create, :destroy]  
  end

  resources :users do
    resources :trails, only: [:create, :destroy]
    collection do
      get 'officers'
    end
  end

  resources :venues
  resources :sessions, only: [:create, :destroy]
  
  match "/auth/:provider/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", as: :sign_out
  root to: 'pages#home'
  
  match '/contact', to: 'pages#contact'
  match '/about',   to: 'pages#about'
  match '/help',    to: 'pages#help'
  match '/roadmap', to: 'pages#roadmap'
  match '/search',  to: 'pages#search'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
