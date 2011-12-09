Gather::Application.routes.draw do
  
  resources :subjects do
     member do
        get 'close_dialog'
    end
  end

  resources :styles

  match 'question_images/:id/new' => 'question_images#new'
  resources :question_images
  devise_for :users
  
  match 'skip_logics/:question_id/new/' => 'skip_logics#new'
  
  
  match 'users/index' => 'users#index'
  match 'users/close_dialog' => 'users#close_dialog'
  
  match 'section/:id/questions/:type/new' => 'questions#new'
  match 'sections/close_dialog' => 'sections#close_dialog'
  resources :sections do
    member do
        post 'save_sort'
    end
    resources :questions
  end
  
  match 'statisticians/:id/password' => 'statisticians#password'
  match 'statisticians/close_dialog' => 'statisticians#close_dialog'
  resources :statisticians do 
    member do
        post 'save_sort'
        get 'close_dialog'
        get 'new_logo'
        get 'show_logo'
        get 'edit_logo'
        post 'update_logo'
        post 'create_logo'
    end
    resources :styles
    resources :sections 
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
  match 'workbench/:id/list_results/:page' => 'workbench#list_results'
  match 'workbench/:section_id/view_survey/:subject_id' => 'workbench#view_survey'
  
  resources :surveys do
    member do
      get 'css_style'
    end
  end
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
  match 'surveys/:id/completed/' => 'surveys#completed'
  #match 'surveys/:id/css_style' => 'surveys#css_style'
  #--------------------------------------------------------------------------#
  
  root :to => "workbench#index"

end
