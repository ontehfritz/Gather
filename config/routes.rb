Gather::Application.routes.draw do
  resources :question_images

  devise_for :users
  #survey -------------------------------------------------------------------
  match 'surveys/:id/subject_authenticate/' => 'surveys#subject_authenticate'
  match 'surveys/:id/authenticate/' => 'surveys#authenticate'
  match 'surveys/:id/information/' => 'surveys#information'
  match 'surveys/:id/power/' => 'surveys#power'
  match 'surveys/:id/declined/' => 'surveys#declined'
  match 'surveys/:id/finish/' => 'surveys#finish'
  match 'surveys/:id/save/' => 'surveys#save'
  match 'surveys/:id/section/' => 'surveys#section'
  match 'surveys/:id/begin/' => 'surveys#begin'
  #--------------------------------------------------------------------------#
  
  match 'skip_logics/:question_id/new/' => 'skip_logics#new'
  
  #match 'elements/:id/edit/' => 'elements#edit'
  #match 'elements/:question_id/new/' => 'elements#new'
  #match 'elements/:id/destroy/' => 'elements#destroy'
  
  
  #match 'questions/:id/new/:types' => 'questions#new'
  #match 'questions/:question_id/edit/' => 'questions#edit'
  #match 'questions/:section_id/index' => 'questions#index'
  #match 'questions/:section_id/save_sort' => 'questions#save_sort'
  
  #match 'sections/:statistician_id/index' => 'sections#index'
  #match 'sections/:statistician_id/new' => 'sections#new'
  #match 'sections/:statistician_id/save_sort' => 'sections#save_sort'
  #match 'sections/close_dialog' => 'sections#close_dialog'
  
  #match 'statisticians/:id/password' => 'statisticians#password'
 
  
  match 'users/index' => 'users#index'
  match 'users/close_dialog' => 'users#close_dialog'
  #resources :questions
  
  match 'sections/close_dialog' => 'sections#close_dialog'
  resources :sections do
    resources :questions
  end
  
  resources :statisticians do 
    member do
        post 'save_sort'
    end
    resources :sections do
      
    end
  end
  
  resources :questions do
      resources :elements
  end
  
  resources :skip_logics
  resources :users

  #get "workbench/index"
  
  match 'workbench/:id' => 'workbench#index'
  match 'workbench/:id/power' => 'workbench#power'
  match 'workbench/:id/link' => 'workbench#link'
  match 'workbench/close' => 'workbench#close'
  match 'workbench/:id/results' => 'workbench#results'
  match 'workbench/:id/question_responses' => 'workbench#question_responses'
  match 'workbench/:id/export_results' => 'workbench#export_results'
  
  match 'question_images/:id/new' => 'question_images#new'


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "workbench#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
