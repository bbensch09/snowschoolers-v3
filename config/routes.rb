Rails.application.routes.draw do

  resources :promo_codes
  resources :shifts
  resources :product_calendars
  resources :selfies
  resources :contestants
  resources :applicants
  get 'apply-to-homewood' => 'applicants#apply'

  resources :sports

  resources :blogs
  get 'blog' => 'blogs#index'
  get 'test-blog' => 'blogs#test_tinymce'
  get 'medium' => 'blogs#medium'
  resources :pre_season_location_requests

  # mount ActionCable.server => '/cable'
  # resources :messages
  # get 'start_conversation/:instructor_id' => 'messages#start_conversation'
  # get 'conversations/:id' => 'messages#show_conversation', as: :show_conversation
  # get 'my_conversations' => 'messages#my_conversations', as: :conversations

  resources :reviews

  resources :snowboard_levels

  resources :ski_levels

  resources :products do
    collection {post :import}
    collection {post :delete_all}
  end

  resources :calendar_blocks
  post 'calendar_blocks/create_10_week_recurring_block' => 'calendar_blocks#create_10_week_recurring_block', as: :create_10_week_recurring_block
  get 'admin-calendar' => 'calendar_blocks#admin_calendar', as: :admin_calendar
  get 'calendar' => 'calendar_blocks#availability', as: :manage_availability
  get 'availability/:id' => 'calendar_blocks#individual_availability', as: :individual_availability
  get 'refresh-calendar' => 'calendar_blocks#refresh_calendar', as: :refresh_calendar
  post 'set-all-days-available/:id' => 'calendar_blocks#set_all_days_available', as: :set_all_days_available
  post 'set-all-weekends-available/:id' => 'calendar_blocks#set_all_weekends_available', as: :set_all_weekends_available
  post 'block-all-days/:id' => 'calendar_blocks#block_all_days', as: :block_all_days
  post 'toggle-availability/:id' => 'calendar_blocks#toggle_availability', as: :toggle_availability

  # mount Ckeditor::Engine => '/ckeditor'
  resources :lesson_actions

  resources :transactions do
    member do
      post :charge_lesson
    end
  end

  resources :locations do 
        collection {post :import}
  end
  resources :charges

  # root to: "lessons#new"
  root to: "welcome#index"

  #backup index
  get 'winter' => 'welcome#index_backup_may2017'

  #twilio testing
  get 'twilio/test_sms' => 'twilio#test_sms'
  #promo pages
  get 'jackson-hole' => "welcome#jackson_hole"
  get 'powder' => "welcome#powder"
  get 'road-conditions' => "welcome#road_conditions"
  get 'accommodations' => "welcome#accommodations"
  get 'resorts' => "welcome#resorts"
  get 'beginners-guide-to-tahoe' => "welcome#beginners_guide_to_tahoe"
  get 'learn-to-ski' => "welcome#learn_to_ski_packages"
  get 'learn-to-ski-packages' => "products#learn_to_ski_packages_search_results", as: :lts_search_results
  get 'private-lessons' => "products#private_lessons_search_results", as: :private_lessons_search_results
  get 'lift-tickets' => "products#lift_tickets_search_results", as: :lift_tickets_search_results
  get 'search' => 'products#search'
  get 'tahoe-season-passes' => 'products#pass_search_results'
  get 'tahoe-season-passes-search-results' => 'products#pass_search_results', as: :pass_search_results
  get 'search-results' => 'products#search_results', as: :search_results 

  get   'lessons/sugarbowl'               => 'lessons#sugarbowl'
  # get 'homewood' => "welcome#homewood"
  get 'homewood2' => "welcome#homewood2"
  #landing page for prospective instructors
  get 'apply' => 'welcome#apply'
  get 'become-a-certified-ski-instructor' => 'welcome#become_a_certified_ski_instructor'
  get 'index' => 'welcome#index'
  get 'about_us' => 'welcome#about_us'
  get 'launch_announcement' => 'welcome#launch_announcement'
  get 'privacy' => 'welcome#privacy'
  get 'terms_of_service' => 'welcome#terms_of_service'
  get 'new_hire_packet' => 'welcome#new_hire_packet'
  get 'recommended_accomodations' => 'welcome#recommended_accomodations'
  get '/thanks-for-applying' => 'instructors#thank_you'
  post '/notify_admin' => 'welcome#notify_admin'
  post 'sumo_success' => 'welcome#sumo_success'
  get '/mountain-collective' => 'welcome#mountain_collective_referral'
  get '/skibutlers' => 'welcome#skibutlers_referral'
  get '/sports-basement' => 'welcome#sportsbasement_referral'
  get '/tahoe-daves' => 'welcome#tahoedaves_referral'
  get '/homewood-learn-to-ski' => 'welcome#homewood_learn_to_ski_referral'
  get '/homewood-kids-lessons' => 'welcome#homewood_kids_lesson_referral'
  get '/homewood-adult-lessons' => 'welcome#homewood_adult_lesson_referral'
  get '/march-madness' => 'welcome#march-madness'
  get '/march-madness-challenge' => 'selfies#march_madness_challenge'
  get '/blog/latest' => 'blogs#latest'
  get '/team-offsites' => 'welcome#team_offsites'
  get '/liftopia' => 'welcome#liftopia_referral'
  get '/homewood-season-pass' => 'welcome#homewood_pass_referral'
  get '/shop/:id' => 'welcome#comparison_shopping_referral'

  # Begin resort referrals
  get '/kirkwood' => 'welcome#kirkwood_referral'
  get '/alpine-meadows' => 'welcome#alpine_referral'
  get '/squaw' => 'welcome#squaw_referral'
  get '/sugar-bowl' => 'welcome#sugar_bowl_referral'
  get '/heavenly' => 'welcome#heavenly_referral'
  get '/northstar' => 'welcome#northstar_referral'
  get '/mt-rose' => 'welcome#mt_rose_referral'
  get '/sierra-at-tahoe' => 'welcome#sierra_referral'
  get '/boreal' => 'welcome#boreal_referral'
  get '/diamond-peak' => 'welcome#diamond_peak_referral'
  get '/tahoe-donner' => 'welcome#tahoe_donner_referral'
  get '/soda-springs' => 'welcome#soda_springs_referral'
  get '/donner-ski-ranch' => 'welcome#donner_ski_ranch_referral'
  get '/granlibakken-group-lessons' => 'welcome#granlibakken_lesssons_referral'
  get '/sky-tavern' => 'welcome#sky_tavern_referral'
  get '/granlibakken' => 'lessons#granlibakken'
  get '/homewood' => 'lessons#homewood'
  get '/daily-roster' => 'lessons#daily_roster'
  get '/payroll-prep' => 'lessons#payroll_prep'

  #Avantlink site verification
  get '/avantlink_confirmation.txt' => 'welcome#avantlink'


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
  get 'profile' => 'instructors#profile'
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

  #Snowschoolers as a Service scheduling views
  get 'schedule' => 'lessons#schedule'  
  get 'schedule-filtered' => 'lessons#lesson_schedule_results', as: :lesson_schedule_results
  # put 'lessons/:id/assign-to-section/:section_id' => 'lessons#assign_to_section', as: :assign_section
  put 'lessons/assign-to-section' => 'lessons#assign_to_section', as: :assign_section
  put 'sections/assign-instructor-to-section' => 'sections#assign_instructor_to_section', as: :assign_instructor_to_section



  resources :sections
  resources :lessons
  # get 'new_request' => 'lessons#new_request'
  get 'new_request/:id' => 'lessons#new_request'
  put   'lessons/:id/set_instructor'      => 'lessons#set_instructor',      as: :set_instructor
  put   'lessons/:id/admin_confirm_instructor'      => 'lessons#admin_confirm_instructor',      as: :admin_confirm_instructor
  put   'lessons/:id/admin_confirm_deposit'      => 'lessons#admin_confirm_deposit',      as: :admin_confirm_deposit
  put   'lessons/:id/admin_assign_instructor'      => 'lessons#admin_assign_instructor',      as: :admin_assign_instructor
  get   'lessons/:id/disable_email_notifications'      => 'lessons#disable_email_notifications',      as: :disable_email_notifications
  get   'lessons/:id/enable_email_notifications'      => 'lessons#enable_email_notifications',      as: :enable_email_notifications
  get   'lessons/:id/disable_sms_notifications'      => 'lessons#disable_sms_notifications',      as: :disable_sms_notifications
  get   'lessons/:id/enable_sms_notifications'      => 'lessons#enable_sms_notifications',      as: :enable_sms_notifications
  put   'lessons/:id/decline_instructor'      => 'lessons#decline_instructor',      as: :decline_instructor
  put   'lessons/:id/remove_instructor'   => 'lessons#remove_instructor',   as: :remove_instructor
  put   'lessons/:id/mark_lesson_complete'   => 'lessons#mark_lesson_complete',   as: :mark_lesson_complete
  patch 'lessons/:id/confirm_lesson_time' => 'lessons#confirm_lesson_time', as: :confirm_lesson_time
  get   'lessons/:id/complete'            => 'lessons#complete',            as: :complete_lesson
  get   'lessons/:id/send_reminder_sms_to_instructor' => 'lessons#send_reminder_sms_to_instructor',  as: :send_reminder_sms_to_instructor
  get   'lessons/:id/send_day_before_reminder_email' => 'lessons#send_day_before_reminder_email',  as: :send_day_before_reminder_email
  get   'lessons/:id/send_review_reminders_to_student' => 'lessons#send_review_reminders_to_student',  as: :send_review_reminders_to_student
  post 'lessons/:id/confirm_reservation'              => 'lessons#confirm_reservation', as: :confirm_reservation
  put 'lessons/:id/issue_refund'              => 'lessons#issue_refund', as: :issue_refund
  put 'lessons/:id/reissue_invoice'              => 'lessons#reissue_invoice', as: :reissue_invoice


  unless Rails.application.config.consider_all_requests_local
    # having created corresponding controller and action
    # get '*path', to: 'application#houston_we_have_500_routing_problems', via: :all
  end

end
