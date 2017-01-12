Rails.application.routes.draw do

  #404 PG
  match "/404", to: "errors#error404", via: :all

  #500 PG
  match '/500', to: 'errors#error500', via: :all

  #SITEMAP
  get "sitemap.xml" => "sitemap#index", as: "sitemap", defaults: { format: "xml" }

  devise_for :users, controllers: { registrations: "registrations", confirmations: "confirmations" }, path_names: {sign_in: "login", sign_out: "logout"}
  
  as :user do
    patch '/user/confirmation' => 'confirmations#update', :via => :patch, :as => :update_user_confirmation
  end

  get 'help/help_contact'

  get 'help/about'

  get 'help/terms_privacy'

  put 'help/help_contact_form'

  namespace :reps do
    devise_for :users, controllers: { registrations: "rep_registrations" },
                                        path_names: {sign_in: "login", sign_out: "logout"},
                                        only: :registrations
  end 

  devise_scope :user do
    put 'checkout' => 'registrations#checkout' 
  end 

  resources :high_schools do
    collection do
      get 'high_school'
      put 'error'
      put 'missing'
      get 'search', path: 'search'
      get 'name_or_ceeb_query_auto_complete'
      get 'city_auto_complete'
      get 'get_counties'
    end
  end
  
  resources :prospective_students do
    collection do
      get "dashboard"
      put "get_prospective_students_by_year"
      get "export"
      put "get_prospective_students_by_id"
      get "send_mail"
      get "send_test_mail"
    end
  end

  resources :users do
    get 'visits_csv' => 'users#visits_csv'
    collection do
      get 'home'
    end 

    resources :high_schools do
      collection do
        get 'all_notes' => 'notes#all_notes'
        get 'keyword_search' => 'notes#keyword_search'
      end  
      resources :notes
    end    
    resources :preferred_phones, only: [:create, :update, :destroy]
    resources :preferred_guidance_websites, only: [:create, :update, :destroy]
    resources :preferred_calendars, only: [:create, :update, :destroy]
    resources :preferred_emails, only: [:create, :update, :destroy]
    resources :saved_searches,  only: [:index,  :create, :destroy]
    resources :visits do
      put 'jsDragUpdate', as: 'drag_update'
      put 'formUpdate', as: 'form_update'
      put 'update_confirmed' => 'visits#update_confirmed'
      collection do
        get 'calendar_feed'
        get 'agenda'
        put 'share'
      end    
    end  
    resources :notes
  end 

	root 'users#home'

  namespace :admin do	   
    resources :high_schools do
      collection do
        post 'import_for_new'
        post 'import_for_update'
        get 'export'
        get 'import_template'
        get 'dashboard'
        get 'search'
      end
    end  
  end

  resources :admin do
    collection do
      resources :admins, controller: 'admin/admins', except: [:show]
    end
  end    
  
  resources :admin do
    collection do
      resources :accounts, controller: 'admin/accounts'
    end  
  end    

  resources :institutions, only: [:none] do 
    collection do
      get 'institution_auto_complete'
      get 'institution'
    end
  end    

  resources :accounts do
    collection do
      get 'credit_card_form'
    end
  end
  
end
