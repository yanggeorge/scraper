Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  #root 'index#index'
  root 'index#projects'
  get 'index/projects' => 'index#projects'
  post 'index/delete_robot' => 'index#delete_robot'
  post 'scrape/do_url' => 'scrape#do_url'
  get 'scrape/do_url' => 'scrape#do_url'
  post 'scrape/get_page_id' => 'scrape#get_page_id'
  get 'scrape/page/:id' => 'scrape#page'
  post 'scrape/save_robot' => 'scrape#save_robot'
  post 'scrape/extract_data' => 'scrape#extract_data'
  post 'scrape/click_element' => 'scrape#click_element'
  post 'scrape/save' => 'scrape#save'
  get 'item/index' => 'item#index'
  post 'item/index' => 'item#index'
  get 'item/show/:id' => 'item#show' , as: :item_show
  post 'item/update/:id' => 'item#update' , as: :item_update

  #root 'home#index'
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
