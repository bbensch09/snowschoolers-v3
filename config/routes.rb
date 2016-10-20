SnowSchoolers::Application.routes.draw do
  resources :products

  resources :calendar_blocks

  mount Ckeditor::Engine => '/ckeditor'
  resources :lesson_actions

  resources :transactions do
    member do
      post :charge_lesson
    end
  end

  resources :locations
  resources :charges

  # root to: "lessons#new"
  root to: "welcome#index"

  #twilio testing
  get 'twilio/test_sms' => 'twilio#test_sms'
  #promo pages
  get 'sugarbowl' => "welcome#sugarbowl"
  get   'lessons/sugarbowl'               => 'lessons#sugarbowl'
  get 'homewood' => "welcome#homewood"
  get 'homewood2' => "welcome#homewood2"
  get   'lessons/homewood'               => 'lessons#homewood'
  #landing page for prospective instructors
  get 'apply' => 'welcome#apply'
  get 'index' => 'welcome#index'
  get 'thank_you' => 'instructors#thank_you'
  post '/notify_admin' => 'welcome#notify_admin'
  resources :instructors do
    member do
        post :verify
        post :revoke
      end
  end
  get '/admin_index' => 'instructors#admin_index'
  get 'browse' => 'instructors#browse'
  get 'search' => 'products#search'
  get 'search_results' => 'products#search_results', as: :search_results
  get 'lessons/book_product/:id' => 'lessons#book_product'
  # post 'search_results' => 'products#search_results', as: :refresh_search_results

  resources :beta_users
  resources :lesson_times
  devise_for :users, controllers: { registrations: 'users/registrations', omniauth_callbacks: "users/omniauth_callbacks" }

  #snowschoolers admin views
  get 'admin_users' => 'welcome#admin_users'
  get 'admin_edit/:id' => 'welcome#admin_edit', as: :admin_edit_user
  get 'users/:id' => 'welcome#admin_show_user', as: :user
  put 'users/:id' => 'welcome#admin_update_user'
  patch 'users/:id' => 'welcome#admin_update_user'
  delete 'users/:id' => 'welcome#admin_destroy', as: :admin_destroy


  resources :lessons
  get 'new_request' => 'lessons#new_request'
  get 'new_request/:id' => 'lessons#new_request'
  put   'lessons/:id/set_instructor'      => 'lessons#set_instructor',      as: :set_instructor
  put   'lessons/:id/decline_instructor'      => 'lessons#decline_instructor',      as: :decline_instructor
  put   'lessons/:id/remove_instructor'   => 'lessons#remove_instructor',   as: :remove_instructor
  put   'lessons/:id/mark_lesson_complete'   => 'lessons#mark_lesson_complete',   as: :mark_lesson_complete
  patch 'lessons/:id/confirm_lesson_time' => 'lessons#confirm_lesson_time', as: :confirm_lesson_time
  get   'lessons/:id/complete'            => 'lessons#complete',            as: :complete_lesson
end
