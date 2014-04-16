Rails.application.routes.draw do
  get 'static_pages/home'

  root 'products#index'

  get '/signin' => 'sessions#new'
  delete '/signout' => 'sessions#destroy'
  resources :sessions, only: [:create]
  get '/signup' => 'users#new'
  resources :users, only: [:create]

  concern :buyable do
    get 'buy' => 'line_items#new'
  end

  resources :products do
    concerns :buyable
    resources :stock_levels, only: [:index, :new, :create]
    resources :sub_products, only: [:index, :new]
  end

  resources :stock_levels, only: [:destroy]

  resources :orders, except: [:destroy, :new, :create] do
    member do
      patch 'set_current'
    end
  end
  resource :cart, only: [:show, :destroy, :update] do
    patch 'confirm'
    patch 'update_address'
  end
  resources :carts, only: [:index]
  get '/checkout' => 'carts#checkout'

  resources :line_items, only: [:show, :create, :destroy, :update]
  resources :currencies, except: :show

  resources :addresses
  resources :postage_costs, except: :show
  

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
