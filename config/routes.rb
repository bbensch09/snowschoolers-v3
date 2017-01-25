Rails.application.routes.draw do

  resources :sports
  mount ActionCable.server => '/cable'

  resources :blogs
  get 'blog' => 'blogs#index'
  resources :pre_season_location_requests

  resources :messages
  get 'start_conversation/:instructor_id' => 'messages#start_conversation'
  get 'conversations/:id' => 'messages#show_conversation', as: :show_conversation
  get 'my_conversations' => 'messages#my_conversations', as: :conversations

  resources :reviews

  resources :snowboard_levels

  resources :ski_levels

  resources :products do
    collection {post :import}
    collection {post :delete_all}
  end

  resources :calendar_blocks
  post 'calendar_blocks/create_10_week_recurring_block' => 'calendar_blocks#create_10_week_recurring_block', as: :create_10_week_recurring_block

  # mount Ckeditor::Engine => '/ckeditor'
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
  get 'jackson-hole' => "welcome#jackson_hole"
  get 'powder' => "welcome#powder"
  get 'road-conditions' => "welcome#road_conditions"
  get 'accommodations' => "welcome#accommodations"
  get 'resorts' => "welcome#resorts"
  get 'beginners_guide_to_tahoe' => "welcome#beginners_guide_to_tahoe"
  get   'lessons/sugarbowl'               => 'lessons#sugarbowl'
  get 'homewood' => "welcome#homewood"
  get 'homewood2' => "welcome#homewood2"
  get   'lessons/homewood'               => 'lessons#homewood'
  #landing page for prospective instructors
  get 'apply' => 'welcome#apply'
  get 'index' => 'welcome#index'
  get 'about_us' => 'welcome#about_us'
  get 'launch_announcement' => 'welcome#launch_announcement'
  get 'privacy' => 'welcome#privacy'
  get 'terms_of_service' => 'welcome#terms_of_service'
  get 'new_hire_packet' => 'welcome#new_hire_packet'
  get 'recommended_accomodations' => 'welcome#recommended_accomodations'
  get 'thank_you' => 'instructors#thank_you'
  post '/notify_admin' => 'welcome#notify_admin'
  resources :instructors do
    member do
        post :verify
        post :revoke
        get :show_candidate
      end
  end
  get '/admin_index' => 'instructors#admin_index'
  get 'lessons/admin_index' => 'lessons#admin_index'
  get 'browse' => 'instructors#browse'
  get 'search' => 'products#search'
  get 'search_results' => 'products#search_results', as: :search_results
  get 'lessons/book_product/:id' => 'lessons#book_product'
  # post 'search_results' => 'products#search_results', as: :refresh_search_results

  resources :beta_users
  resources :lesson_times
  devise_for :users, controllers: { registrations: 'users/registrations', confirmations: 'users/registrations', omniauth_callbacks: "users/omniauth_callbacks" }

  #snowschoolers admin views
  get 'admin_users' => 'welcome#admin_users'
  get 'admin_edit/:id' => 'welcome#admin_edit', as: :admin_edit_user
  get 'users/:id' => 'welcome#admin_show_user', as: :user
  put 'users/:id' => 'welcome#admin_update_user'
  patch 'users/:id' => 'welcome#admin_update_user'
  delete 'users/:id' => 'welcome#admin_destroy', as: :admin_destroy


  resources :lessons
  # get 'new_request' => 'lessons#new_request'
  get 'new_request/:id' => 'lessons#new_request'
  put   'lessons/:id/set_instructor'      => 'lessons#set_instructor',      as: :set_instructor
  put   'lessons/:id/decline_instructor'      => 'lessons#decline_instructor',      as: :decline_instructor
  put   'lessons/:id/remove_instructor'   => 'lessons#remove_instructor',   as: :remove_instructor
  put   'lessons/:id/mark_lesson_complete'   => 'lessons#mark_lesson_complete',   as: :mark_lesson_complete
  patch 'lessons/:id/confirm_lesson_time' => 'lessons#confirm_lesson_time', as: :confirm_lesson_time
  get   'lessons/:id/complete'            => 'lessons#complete',            as: :complete_lesson
  get   'lessons/:id/send_reminder_sms_to_instructor' => 'lessons#send_reminder_sms_to_instructor',  as: :send_reminder_sms_to_instructor
  post 'lessons/:id/confirm_reservation'              => 'lessons#confirm_reservation', as: :confirm_reservation
end
