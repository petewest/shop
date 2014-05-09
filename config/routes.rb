Rails.application.routes.draw do
  get 'static_pages/home'

  root 'products#index'

  get '/signin' => 'sessions#new'
  delete '/signout' => 'sessions#destroy'
  resources :sessions, only: [:create]
  get '/signup' => 'users#new'
  get '/my_account' => 'users#edit'
  resource :user, only: [:create, :update] do
    member do
      get 'password'
      patch 'update_password'
      post 'update_password'
    end
  end

  concern :buyable do
    get 'buy' => 'line_items#new'
  end

  resources :charges, only: [:index, :show] do
    member do
      post 'refund'
      patch 'refund'
    end
  end

  resources :postage_services, except: [:show] do
    resources :postage_costs, only: [:new]
  end

  resources :products do
    concerns :buyable
    resources :stock_levels, only: [:index, :new, :create]
    resources :sub_products, only: [:index, :new]
    resources :allocations, only: [:index]
  end

  resources :gift_card_products, only: :index do
    concerns :buyable
  end

  resources :gift_card_products, only: :show, controller: :products

  resources :gift_cards, only: [:index] do
    collection do
      get :redeem
      post :allocate
      patch :allocate
    end
  end

  resources :stock_levels, only: [:destroy] do
    resources :orders, only: [:index], module: :seller
    resources :allocations, only: [:index]
  end

  resources :allocations, only: [:index]

  resources :images, only: [:show]

  resources :orders, except: [:destroy, :new, :create, :edit] do
    member do
      patch 'set_current'
      get 'pay'
      patch 'cancel'
    end
    resources :redemptions, only: [:create, :destroy], shallow: true
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

  # Seller namespace for controllers that will behave differently
  # for sellers than for buyers
  namespace :seller do
    get '/allocations/:allocation_id/gift_cards' => 'gift_cards#index', as: :allocation_gift_cards
    resources :orders, only: [:index, :show, :update]
    resources :products, only: [:index]
    resources :gift_card_products, except: :show
    resources :gift_cards, except: :show
    resources :users, only: [:index] do
      resources :orders, only: :index
      get '/allocations' => '/allocations#index'
    end
  end
  

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
