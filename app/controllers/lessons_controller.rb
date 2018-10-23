class LessonsController < ApplicationController
  respond_to :html
  skip_before_action :authenticate_user!, only: [:new, :granlibakken, :new_request, :create, :complete, :confirm_reservation, :update, :show, :edit]
  before_action :set_lesson, only: [:show, :complete, :update, :edit, :edit_wages, :destroy, :send_reminder_sms_to_instructor, :reissue_invoice, :issue_refund, :confirm_reservation, :admin_reconfirm_state, :decline_instructor, :remove_instructor, :mark_lesson_complete, :confirm_lesson_time, :set_instructor, :authenticate_from_cookie, :send_day_before_reminder_email, :admin_confirm_instructor, :admin_confirm_deposit, :admin_assign_instructor, :enable_email_notifications, :disable_email_notifications, :enable_sms_notifications, :disable_sms_notifications, :send_review_reminders_to_student]
  before_action :save_lesson_params_and_redirect, only: [:create]
  # before_action :authenticate_from_cookie!, only: [:complete, :confirm_reservation, :update, :show, :edit]

  def assign_to_section
    puts "the params are #{params}"
    @lesson = Lesson.find(params[:lesson_id])
    @section = Section.find(params[:section_id])
    @lesson.section_id = @section.id
    @lesson.save!
    redirect_to "/schedule-filtered?utf8=✓&search_date=#{@section.parametized_date}&age_type=#{@section.age_group}"    
  end

  def admin_index
    @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed?}
    @lessons.sort! { |a,b| a.lesson_time.date <=> b.lesson_time.date }
  end

  def schedule
      # @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed?}
      render 'schedule_new'
  end

  def lesson_schedule_results
      @date = params[:search_date]
      @age_type = params[:age_type] ? params[:age_type] : ["Kids","Adults","Any"]
      @lessons = Lesson.all.to_a.keep_if{ |lesson| lesson.lesson_time.date.to_date.strftime("%m/%d/%Y") == @date }
      @ski_sections = Section.all.to_a.keep_if {|section| section.date.strftime("%m/%d/%Y") == @date && @age_type.include?(section.age_group) && section.sport_id == 1}
      @sb_sections = Section.all.to_a.keep_if {|section| section.date.strftime("%m/%d/%Y") == @date && @age_type.include?(section.age_group) && section.sport_id == 3}
      @lessons.sort! { |a,b| a.id <=> b.id }
    render 'schedule'
  end

  #WORK IN PROGRESS - Jan1
  def search
    @lessons = Lesson.all.select{|lesson| lesson.booked? && lesson.this_season? }
    # @lessons = @lessons.sort! { |a,b| a.lesson_time.date <=> b.lesson_time.date }
    respond_to do |format|
          format.html {render 'search_results'}
          format.csv { send_data @lessons.to_csv, filename: "private-lessons-export-#{Date.today}.csv" }
        end
  end

  def search_results
    search_params = {email: params[:search], name: params[:name], date: params[:date], gear:params[:gear], incomplete:params[:incomplete], instructor:params[:instructor]}
    puts "!!!!! the search_params are: #{search_params}"
    @lessons = Lesson.all
    if params[:date] != ""      
        puts "!!!filter by date.  param is #{params['date']}"
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.date.to_s == params[:date]}  
        puts "found #{@lessons.count} mactching lessons"
    end
    if params[:location] != ""
        puts "!!!filter by location.  param is #{params['location']}"
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.location.name.include?(params[:location])}  
        puts "found #{@lessons.count} mactching lessons"
    end 
    if params[:instructor] != ""
        puts "!!!filter by instructor.  param is #{params['instructor']}"
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.instructor && lesson.instructor.name.include?(params[:instructor])}  
        puts "found #{@lessons.count} mactching lessons"
    end 
    if params[:email] != ""
        puts "!!!filter by email. email param is #{params['email']}"
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.contact_email && lesson.contact_email.include?(params[:email])}  
        # @lessons = Lesson.all.select{|lesson| lesson.email == 'brian@snowschoolers.com'}  
        puts "found #{@lessons.count} mactching lessons"
    end  
    if params['gear'] != ""
        puts "!!!filtering for reservations with rentals."
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.includes_rental_package?}  
        puts "found #{@lessons.count} mactching lessons"
    end  
      puts "!!!! @lessons.count is #{@lessons.count}"
    unless params['incomplete'] != ""
      @lessons = @lessons.to_a.keep_if{|lesson| lesson.booked? && lesson.this_season? }    
    end
    respond_to do |format|
      format.html {render 'search_results'}
      format.csv { send_data @lessons.to_csv, filename: "private-lessons-export-#{Date.today}.csv" }
    end
  end

  def payroll_prep
    if current_user.email == "brian@snowschoolers.com" && params[:instructor].nil?
      @lessons = Lesson.all.select{|lesson| lesson.eligible_for_payroll? && lesson.date < Date.today }
    elsif current_user.email == "brian@snowschoolers.com" && params[:instructor]
      puts "!!!!filtering for instructor params"
      instructor = Instructor.all.select{|i| params[:instructor].downcase == i.to_param}
      @lessons = Lesson.all.select{|lesson| lesson.eligible_for_payroll? && lesson.date < Date.today && lesson.instructor_id == instructor.first.id }
    elsif current_user && current_user.instructor
      @lessons = Lesson.all.select{|lesson| lesson.eligible_for_payroll? && lesson.instructor_id == current_user.instructor.id && lesson.date < Date.today }
    end
    # @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed?|| lesson.canceled? || lesson.booked? || lesson.state.nil? }
    @lessons.sort_by!{|lesson| [lesson.date, lesson.instructor.name]}
    @payroll_total = Lesson.payroll_total(@lessons)
    render 'payroll_prep'
  end

  def daily_roster
    lessons = Lesson.all.select{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.booked? || lesson.state.nil? }
    @todays_lessons = lessons.select{|lesson| lesson.date == Date.today && lesson.state != 'canceled' }
    @tomorrows_lessons = lessons.to_a.keep_if{|lesson| lesson.date == Date.today+1 && lesson.state != 'canceled' }
    render 'daily_roster'
  end

  def index
    if current_user.email == "brian@snowschoolers.com" || current_user.user_type == "Snow Schoolers Employee"
      @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.canceled? || lesson.booked? || lesson.state.nil? }
      @lessons = @lessons.select{|lesson| lesson.this_season?}
      @lessons = @lessons.select{|lesson| lesson.private_lesson?}
      @lessons.sort! { |a,b| a.lesson_time.date <=> b.lesson_time.date }
      @todays_lessons = Lesson.all.to_a.keep_if{|lesson| lesson.date == Date.today }
      @wage_rate = current_user.instructor ? current_user.instructor.wage_rate : nil
      elsif current_user.user_type == "Ski Area Partner"
        lessons = Lesson.where(requested_location:current_user.location.id.to_s).sort_by { |lesson| lesson.id}
        @todays_lessons = lessons.to_a.keep_if{|lesson| lesson.date == Date.today && lesson.state != 'new' }
        @lessons = Lesson.where(requested_location:current_user.location.id.to_s).to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed?}
        @lessons.sort_by { |lesson| lesson.id}
      elsif current_user.instructor
        lessons = Lesson.visible_to_instructor?(current_user.instructor)
        @todays_lessons = lessons.to_a.keep_if{|lesson| lesson.date == Date.today }
        @lessons = Lesson.visible_to_instructor?(current_user.instructor)
        @wage_rate = current_user.instructor ? current_user.instructor.wage_rate : nil
      else
        @lessons = current_user.lessons
        @todays_lessons = current_user.lessons.to_a.keep_if{|lesson| lesson.date == Date.today }
    end
  end

  def group_index
    if current_user && (current_user.user_type == 'Ski Area Partner' || current_user.email == 'brian@snowschoolers.com')
      all_days = Section.select(:date).distinct.sort{|a,b| a.date <=> b.date}
      @days = all_days.keep_if{|a| a.date >= Date.today}
      @days = @days.first(30)
      @new_date = Section.new
      @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable?}
      # @lessons.sort! { |a,b| a.lesson_time.date <=> b.lesson_time.date }
      if session[:notice]
        flash.now[:notice] = session[:notice]
      end
    elsif current_user
        @lessons = Lesson.where(requester_id:current_user.id)
        if @lessons.count > 0
          @new_date = Section.new
          days =[]
          @lessons.each do |lesson|
            days << Section.select(:date).where(date:lesson.lesson_time.date).first
          end
          @days = days
          render 'index'
        else
          redirect_to root_path
          flash[:notice] = "You do not have permission to view that page."
        end
    end
  end

  def filtered_group_lesson_reservations
    search_params = {email: params[:search], name: params[:name], date: params[:date], gear:params[:gear]}
    puts "!!!!! the search_params are: #{search_params}"
    @lessons = Lesson.all
    if params[:date] != ""      
        puts "!!!filter by date.  param is #{params['date']}"
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.date.to_s == params[:date]}  
        puts "found #{@lessons.count} mactching lessons"
    end
    if params[:name] != ""
        puts "!!!filter by name.  param is #{params['name']}"
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.name == params[:name]}  
        puts "found #{@lessons.count} mactching lessons"
    end 
    if params['email'] != ""
        puts "!!!filter by email. email param is #{params['email']}"
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.email == params[:email]}  
        # @lessons = Lesson.all.select{|lesson| lesson.email == 'brian@snowschoolers.com'}  
        puts "found #{@lessons.count} mactching lessons"
    end  
    if params['gear'] == "on"
        puts "!!!filtering for resrations with rentals."
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.gear == true}  
        puts "found #{@lessons.count} mactching lessons"
    end  
    puts "!!!! @lessons.count is #{@lessons.count}"
    @lessons = @lessons.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.finalizing? || lesson.booked? || lesson.payment_complete? || lesson.ready_to_book? || lesson.waiting_for_review?}
    render 'admin_index'
  end

  def filtered_group_schedule_results
      date = params[:date]
      puts "!!! filtere date: #{date}"
      all_days = Section.select(:date).distinct
      @days = all_days.to_a.keep_if{|a| a.date.to_s == params[:date]}
      puts "!!!filter by date.  param is #{params['date']}"
      @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.date.to_s == params[:date]}       
        puts "found #{@lessons.count} mactching lessons"
      @todays_lessons = []
      @new_date = Section.new
      render 'index'
  end


  def send_reminder_sms_to_instructor
    if @lesson.instructor.nil?
      puts "!!!instructor = nil"
      instructor = Instructor.find(params[:instructor_id])
      @lesson.send_manual_sms_request_to_instructor(instructor)
    elsif @lesson.completable?
      puts "!!!instructor found, lesson is compeltable"
      @lesson.send_sms_reminder_to_instructor_complete_lessons
    end
    redirect_to @lesson
  end

  def send_review_reminders_to_student
    return unless @lesson.state == 'finalizing payment & reviews'
    @lesson.send_sms_to_requester
    LessonMailer.send_payment_email_to_requester(@lesson.id).deliver!
    redirect_to lessons_path
  end

  def send_day_before_reminder_email
    puts "!!!!sending reminder email to both student & instructor"
    LessonMailer.send_day_before_reminder_email(@lesson.id).deliver!
    redirect_to lessons_path
  end

  def sugarbowl
    @lesson = Lesson.new
    @promo_location = 9
    @lesson_time = @lesson.lesson_time
    render 'new'
  end

  def homewood
    @lesson = Lesson.new
    @promo_location = 8
    @lesson_time = @lesson.lesson_time
    render 'new'
  end

  def granlibakken
    @lesson = Lesson.new
    @promo_location = 24
    @lesson_time = @lesson.lesson_time
    render 'new'
  end

  def book_product
    @lesson = Lesson.new
    @promo_location = Product.find(params[:id]).location.id
    @slot = Product.find(params[:id]).name.to_s
    puts "The selected slot is #{@slot}"
    @lesson_time = @lesson.lesson_time
    render 'new'
  end

  def new
    @lesson = Lesson.new
    @promo_location = session[:lesson].nil? ? nil : session[:lesson]["requested_location"]
    @product_name = session[:lesson].nil? ? nil : session[:lesson]["product_name"]
    @activity = session[:lesson].nil? ? nil : session[:lesson]["activity"]
    @slot = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?) ? nil : session[:lesson]["lesson_time"]["slot"]
    @date = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?)  ? nil : session[:lesson]["lesson_time"]["date"]
    @lesson_time = @lesson.lesson_time
    GoogleAnalyticsApi.new.event('lesson-requests', 'load-lessons-new')
  end

  def new_request
    puts "!!! processing instructor request; Session variable is: #{session[:lesson]}"
    @lesson = Lesson.new
    @promo_location = session[:lesson].nil? ? nil : session[:lesson]["requested_location"]
    @activity = session[:lesson].nil? ? nil : session[:lesson]["activity"]
    @slot = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?) ? nil : session[:lesson]["lesson_time"]["slot"]
    @date = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?)  ? nil : session[:lesson]["lesson_time"]["date"]
    names = params[:id].gsub("-"," ")
    @instructor_requested = Instructor.all.select{|instructor| instructor.name.downcase == names.downcase}.first
    @lesson_time = @lesson.lesson_time
    GoogleAnalyticsApi.new.event('lesson-requests', 'load-lessons-new-private-request')
    render 'new'
  end

  def create
    if params["commit"] == "Book Lesson" || params["commit"] == "GET STARTED"
      puts "!!!! lesson successfully intiated"
      create_lesson_and_redirect
    else
      puts "!!!parms not set as expected"
      session[:lesson] = params[:lesson] 
      flash.now[:alert] = "In order to book a lesson, please select a specific date, time, sport, and location."   
      redirect_to '#book-a-lesson'
    end
  end

  def complete    
    @lesson_time = @lesson.lesson_time
    @product_name = @lesson.product_name
    @slot = @lesson.slot
    @promo_code = PromoCode.new
    GoogleAnalyticsApi.new.event('lesson-requests', 'load-full-form')
    flash.now[:notice] = "You're almost there! We just need a few more details."
    flash[:complete_form] = 'TRUE'
    cookies[:lesson] = {
      value: @lesson.id + 30,
      expires: 1.year.from_now
    }
  end

  def edit    
    @lesson_time = @lesson.lesson_time
    @state = @lesson.instructor ? 'pending instructor' : @lesson.state
  end

  def edit_wages   
    @lesson_time = @lesson.lesson_time 
    @state = @lesson.state
  end

  def reissue_invoice
    @lesson_time = @lesson.lesson_time
    @lesson.state == "ready_to_book"
    @lesson.deposit_status = 'pending_new_payment'
    @lesson.save
    render 'edit'
  end

  def issue_refund
    @lesson_time = @lesson.lesson_time
    render 'edit'
  end

  def confirm_reservation
    if @lesson.deposit_status != 'confirmed'
        if @lesson.lesson_price.nil?
          amount_in_cents = (@lesson.price.to_f*100).to_i
        else
          amount_in_cents= (@lesson.lesson_price.to_f*100).to_i
        end
          customer = Stripe::Customer.create(
            :email => params[:stripeEmail],
            :source  => params[:stripeToken]
          )
          charge = Stripe::Charge.create(
            :customer    => customer.id,
            :amount      => amount_in_cents,
            :description => 'Lesson reservation deposit',
            :currency    => 'usd'
          )
        @lesson.deposit_status = 'confirmed'
        #at time of deposit, record the transaction amount as lesson_price, that way if pricing changes later, can calculate diff.
        @lesson.lesson_price = @lesson.price 
        if @lesson.is_gift_voucher?
          @lesson.state = 'gift_voucher_reserved'
        elsif @lesson.instructor && @lesson.package_info
            @lesson.state = 'confirmed'
        else
          @lesson.state = 'booked'
        end
        puts "!!!!!About to save state & deposit status after processing lessons#update"
        @lesson.save
      GoogleAnalyticsApi.new.event('lesson-requests', 'deposit-submitted', params[:ga_client_id])
      if @lesson.promo_code
        LessonMailer.send_promo_redemption_notification(@lesson).deliver!
      end
      LessonMailer.send_lesson_request_notification(@lesson).deliver!
      if @lesson.group_lesson?
        flash[:notice] = 'Thank you, your lesson request was successful. If you have any questions, please email support@snowschoolers.com.'
      else 
        flash[:notice] = 'Thank you, your lesson request was successful. You will receive an email notification when your instructor confirmed your request. If you have any questions, please email support@snowschoolers.com.'
      end
      flash[:conversion] = 'TRUE'
      puts "!!!!!!!! Lesson deposit successfully charged"
    end
    respond_with @lesson
  end

  def update
    @original_lesson = @lesson.dup
    @lesson.assign_attributes(lesson_params)
    @lesson.lesson_time = @lesson_time = LessonTime.find_or_create_by(lesson_time_params)
    @lesson.product_name = @lesson.slot
    unless current_user && current_user.user_type == "Snow Schoolers Employee"
      @lesson.requester = current_user
    end
    if @lesson.guest_email
      if User.find_by_email(@lesson.guest_email.downcase)
          @lesson.requester_id = User.find_by_email(@lesson.guest_email.downcase).id
          puts "!!!! user is checking out as guest; found matching email from previous entry"
      else
          User.create!({
          email: @lesson.guest_email,
          password: 'homewood_temp_2017',
          user_type: "Student",
          name: "#{@lesson.guest_email}"
          })
         @lesson.requester_id = User.last.id
      puts "!!!! user is checking out as guest; create a temp email for them that must be confirmed"
      end
    end
    if @lesson.is_gift_voucher? && current_user.user_type == "Snow Schoolers Employee" && @lesson.requester_id.nil?
      @user = User.new({
          email: @lesson.gift_recipient_email,
          password: 'homewood_temp_2017',
          user_type: "Student",
          name: "#{@lesson.gift_recipient_name}"
        })
      @user.skip_confirmation!
      @user.save!
      @lesson.requester_id = User.last.id
      puts "!!!! admin is creating a new user to receive a gift voucher; new user need not be confirmed"
    end
    if current_user && @lesson.is_gift_voucher? && current_user.email == @lesson.gift_recipient_email.downcase
      @lesson.state = 'booked'
      puts "!!!! marking voucher as booked & sending SMS to instructors"
    end
    unless @lesson.deposit_status == 'confirmed'
      @lesson.state = 'ready_to_book'
    end
    if @lesson.save
      GoogleAnalyticsApi.new.event('lesson-requests', 'full_form-updated', params[:ga_client_id])
      @user_email = current_user ? current_user.email : "unknown"
      if @lesson.state == "ready_to_book"
      LessonMailer.notify_admin_lesson_full_form_updated(@lesson.id).deliver!
      # LessonMailer.notify_admin_lesson_full_form_updated(@lesson.id).deliver_in(2.seconds)
      # LessonMailer.test_email(@lesson.id).deliver_in(2.seconds)
      # LessonMailer.test_email.deliver_at(Time.parse('2017-12-20 16:20:00 -0800'))
      end
      send_lesson_update_notice_to_instructor
      puts "!!!! Lesson update saved; update notices sent"
    else
      determine_update_state
      puts "!!!!!Lesson NOT saved, update notices determined by 'determine update state' method...?"
    end
    respond_with @lesson
  end

  def show
    if @lesson.state == "ready_to_book"
      GoogleAnalyticsApi.new.event('lesson-requests', 'ready-for-deposit')
    end
    check_user_permissions
  end

  def destroy
    @lesson.update(state: 'canceled',instructor_id:nil)
    send_cancellation_email_to_instructor
    flash[:notice] = 'Your lesson has been canceled.'
    redirect_to @lesson
  end

  def admin_confirm_instructor
    @lesson.state = 'confirmed'
    @lesson.save
    redirect_to @lesson
  end

  def admin_confirm_deposit
    @lesson.deposit_status = 'confirmed'
    @lesson.state = 'booked'
    @lesson.save
    redirect_to @lesson
  end

  def admin_assign_instructor
    puts "!!! params are #{params[:instructor_id]}"
    @lesson.instructor_id = params[:instructor_id]
    @lesson.save
    redirect_to @lesson
  end

  def enable_email_notifications
      session[:disable_email] = 'enabled'
      puts "!!!!session variable set and marked to: #{session[:disable_email]}"
      redirect_to @lesson
  end

  def disable_email_notifications
      session[:disable_email] = 'disabled'
      redirect_to @lesson
  end

  def enable_sms_notifications
      session[:disable_sms] = 'enabled'
      puts "!!!!session variable set and marked to: #{session[:disable_sms]}"
      redirect_to @lesson
  end

  def disable_sms_notifications
      session[:disable_sms] = 'disabled'
      redirect_to @lesson
  end

  def set_instructor
    @lesson.instructor_id = current_user.instructor.id
    @lesson.state = 'confirmed'
    if @lesson.save
    l = LessonAction.find_or_create_by!({
      lesson_id: @lesson.id,
      instructor_id: current_user.instructor.id,
      })
    l.action = "Accept"
    l.save
    c = CalendarBlock.find_or_create_by!({
        date: @lesson.lesson_time.date,
        instructor_id: current_user.instructor.id,
        })
      c.state = 'Booked'
      c.lesson_time_id = @lesson.lesson_time_id
      c.save
    if @lesson.location.id == 8
      LessonMailer.send_lesson_hw_confirmation(@lesson).deliver!
    elsif @lesson.location.id == 24
      LessonMailer.send_lesson_gb_confirmation(@lesson).deliver!
    end
    @lesson.send_sms_to_requester
    redirect_to @lesson
    else
     redirect_to @lesson, notice: "Error: could not accept lesson. #{@lesson.errors.full_messages}"
    end
  end

  def decline_instructor
    LessonAction.create!({
      lesson_id: @lesson.id,
      instructor_id: current_user.instructor.id,
      action: "Decline"
      })
    if @lesson.instructor
        @lesson.send_sms_to_admin_1to1_request_failed
        @lesson.update(state: "requested instructor not available")
      elsif @lesson.available_instructors.count >= 1
      @lesson.send_sms_to_instructor
      else
      @lesson.send_sms_to_admin
    end
    flash[:notice] = 'You have declined the request; another instructor has now been notified.'
    # LessonMailer.send_lesson_confirmation(@lesson).deliver!
    redirect_to @lesson
  end

  def remove_instructor
    @canceling_instructor = @lesson.instructor.email
    puts "!!!!!!the canceling instructor is #{@canceling_instructor}"
    c = CalendarBlock.find_or_create_by!({
        date: @lesson.lesson_time.date,
        instructor_id: current_user.instructor.id,
        })
    c.state = 'Dropped Lesson'
    c.save
    @lesson.instructor = nil
    @lesson.update(state: 'seeking replacement instructor')
    @lesson.send_sms_to_requester
    if @lesson.available_instructors?
      @lesson.send_sms_to_instructor
      else
      @lesson.send_sms_to_admin
    end
    send_instructor_cancellation_emails
    redirect_to @lesson
  end

  def mark_lesson_complete
    puts "the params are {#{params}"
    @lesson.state = 'finalizing'
    @lesson.save
    redirect_to @lesson
  end

  def confirm_lesson_time
    if valid_duration_params?
      @lesson.update(lesson_params.merge(state: 'waiting for review'))
      @lesson.state = @lesson.valid? ? 'waiting for review' : 'confirmed'
      @lesson.send_sms_to_requester
      LessonMailer.send_payment_email_to_requester(@lesson.id).deliver!
    else
      puts "!!!!error on entering valid duration params"
    end
    respond_with @lesson, action: :show
  end

  private

  def valid_duration_params?
    if params[:lesson].nil? #params[:lesson][:actual_start_time].nil? || params[:lesson][:actual_end_time].nil?  || params[:lesson][:public_feedback_for_student].nil?
      flash[:alert] = "Please confirm start & end time, as well as lesson duration."
      return false
    else
      session[:lesson] = params[:lesson]
      return true
    end
  end

  def validate_new_lesson_params
    if params[:lesson].nil? || params[:lesson][:requested_location].to_i < 1 || params[:lesson][:lesson_time][:date].length < 10
      flash[:alert] = "Please be sure to select a sport, location, date and time."
      redirect_to '#book-a-lesson'
    else
      session[:lesson] = params[:lesson]
    end
  end

  def save_lesson_params_and_redirect
    puts "!!!!! params are below: #{params}"
    puts params[:lesson][:activity]
    puts params[:lesson][:lesson_time][:date]
    puts params[:lesson][:lesson_time][:slot]
    puts "!!!!!!! end params"
    validate_new_lesson_params
  end

  def create_lesson_and_redirect
    @lesson = Lesson.new(lesson_params)
    @lesson.requester = current_user
    @lesson.lesson_time = @lesson_time = LessonTime.find_or_create_by(lesson_time_params)
    @lesson.product_name = @lesson.lesson_time.slot
    if @lesson.save
      GoogleAnalyticsApi.new.event('lesson-requests', 'request-initiated', params[:ga_client_id])
      @user_email = current_user ? current_user.email : "unknown"
      cookies[:lesson] = {
        value: @lesson.id + 30,
        expires: 1.year.from_now
      }
      redirect_to complete_lesson_path(@lesson)
      # LessonMailer.notify_admin_lesson_request_begun(@lesson, @user_email).deliver!
      else
        @activity = session[:lesson].nil? ? nil : session[:lesson]["activity"]
        @promo_location = session[:lesson].nil? ? nil : session[:lesson]["requested_location"]
        @slot = session[:lesson].nil? ? nil : session[:lesson]["lesson_time"]["slot"]
        @date = session[:lesson].nil? ? nil : session[:lesson]["lesson_time"]["date"]
        render 'new'
    end
  end

  def send_cancellation_email_to_instructor
    if @lesson.instructor.present?
      LessonMailer.send_cancellation_email_to_instructor(@lesson).deliver!
    end
  end

  def send_instructor_cancellation_emails
    LessonMailer.send_cancellation_confirmation(@canceling_instructor,@lesson).deliver!
    LessonMailer.send_lesson_request_to_new_instructors(@lesson, @lesson.instructor).deliver! if @lesson.available_instructors?
    LessonMailer.inform_requester_of_instructor_cancellation(@lesson, @lesson.available_instructors?).deliver!
  end

  def send_lesson_update_notice_to_instructor
    return unless @lesson.deposit_status == 'confirmed'
    if @lesson.instructor.present?
      changed_attributes = @lesson.get_changed_attributes(@original_lesson)
      return unless changed_attributes.any?
      return unless current_user.email != "brian@snowschoolers.com"
      LessonMailer.send_lesson_update_notice_to_instructor(@original_lesson, @lesson, changed_attributes).deliver!
    end
  end

  def check_user_permissions
    return unless @lesson.guest_email.nil?    
  end

  def authenticate_from_cookie!
    puts "!!! params for :allow are #{params[:allow]}"
    cookie_expected = @lesson.id + 30
    unless cookies[:lesson].to_i == cookie_expected.to_i || (current_user && current_user.user_type == 'Snow Schoolers Employee') || (current_user && current_user.instructor) || params[:allow] == 'true'
      puts "!!! current cookie value for lesson is: #{cookies[:lesson]} and expected value is: #{cookie_expected}"
      puts "!!!! cookie does not match!"
      session[:must_sign_in] = true
      redirect_to root_path
    end
    if params[:allow] == 'true'
      cookies[:lesson] = {
        value: @lesson.id + 30,
        expires: 1.year.from_now
      }
      puts"!!!! cookie has been set to: #{cookies[:lesson]}."
    end
  end

  def determine_update_state
    @lesson.state = 'new' unless params[:lesson][:terms_accepted] == '1'
    if @lesson.deposit_status == 'confirmed' && @lesson.is_gift_voucher == false
      flash.now[:notice] = "Your lesson deposit has been recorded, but your lesson reservation is incomplete. Please fix the fields below and resubmit."
      @lesson.state = 'booked'
    elsif @lesson.deposit_status == 'confirmed' && @lesson.is_gift_voucher == true
      flash.now[:notice] = "Lesson voucher information has been updated."
    end
    @lesson.save
    @state = params[:lesson][:state]
  end

  def set_lesson
      @lesson = Lesson.find(params[:id])
  end

  def lesson_params
    params.require(:lesson).permit(:activity, :phone_number, :requested_location, :state, :student_count, :gear, :lift_ticket_status, :objectives, :duration, :ability_level, :start_time, :actual_start_time, :actual_end_time, :actual_duration, :terms_accepted, :deposit_status, :public_feedback_for_student, :private_feedback_for_student, :instructor_id, :focus_area, :requester_id, :guest_email, :how_did_you_hear, :num_days, :lesson_price, :requester_name, :is_gift_voucher, :includes_lift_or_rental_package, :package_info, :gift_recipient_email, :gift_recipient_name, :lesson_cost, :non_lesson_cost, :product_id, :section_id, :product_name, :admin_price_adjustment, :promo_code_id, :planned_start_time, :payment_status, :payment_method, :payment_date, :hourly_bonus, :bonus_category, :additional_info, :class_type,
      students_attributes: [:id, :name, :age_range, :gender, :relationship_to_requester, :lesson_history, :requester_id, :most_recent_experience, :most_recent_level, :other_sports_experience, :experience, :_destroy, :needs_rental, :shoe_size, :height_feet, :height_inches, :weight, :skier_type, :poles_requested, :board_direction], lesson_time_attributes: [:date, :slot])
  end

  def lesson_time_params
    params[:lesson].require(:lesson_time).permit(:date, :slot)
  end
end
