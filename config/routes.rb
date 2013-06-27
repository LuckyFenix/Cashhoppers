CashHoppers::Application.routes.draw do

  resources :ads


  resources :ad_types


  root :to => 'pages#home'

  namespace :admin do
    get 'pages/index', :as => 'index'
    resources :applications
  end

  get "pages/home"

  devise_for :users do
    namespace :api do
      post 'sessions' => 'sessions#create', :as => 'login'
      get 'sign_up' => 'sessions#sign_up', :as => 'sign_up'

      post 'send_ad' => 'ad#send_ad' ,   :as => 'send_ad'


      delete 'sessions' => 'sessions#destroy', :as => 'logout'
    end
  end


  match '/auth/:service/callback' => 'services#add_zip'

  get 'services/add_zip', :to => 'services#add_zip'
 
  resources :services, :only => [:index, :create, :destroy]

end
