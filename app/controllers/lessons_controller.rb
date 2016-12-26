class LessonsController < ApplicationController
  respond_to :html
  skip_before_action :authenticate_user!, only: [:new, :create, :complete, :confirm_reservation, :update, :show, :edit]
  before_action :save_lesson_params_and_redirect, only: [:create]
  before_action :create_lesson_from_session, only: [:create]

  def index
    if current_user.email == "brian@snowschoolers.com"
      @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable?}
      @lessons.sort_by { |lesson| lesson.id}
      @todays_lessons = Lesson.all.to_a.keep_if{|lesson| lesson.date == Date.today }
      elsif current_user.user_type == "Ski Area Partner"
        lessons = Lesson.where(requested_location:current_user.location.id.to_s).sort_by { |lesson| lesson.id}
        @todays_lessons = lessons.to_a.keep_if{|lesson| lesson.date == Date.today && lesson.state != 'new' }
        @lessons = Lesson.where(requested_location:current_user.location.id.to_s).to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable?}
        @lessons.sort_by { |lesson| lesson.id}
      elsif current_user.instructor
        lessons = Lesson.visible_to_instructor?(current_user.instructor)
        @todays_lessons = lessons.to_a.keep_if{|lesson| lesson.date == Date.today }
        @lessons = Lesson.visible_to_instructor?(current_user.instructor)
      else
        @lessons = current_user.lessons
        @todays_lessons = current_user.lessons.to_a.keep_if{|lesson| lesson.date == Date.today }
    end
  end

  def sugarbowl
    @lesson = Lesson.new
    @promo_location = 9
    @lesson_time = @lesson.lesson_time
    render 'new'
  end

  def homewood
    @lesson = Lesson.new
    @promo_location = 6
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
    @activity = session[:lesson].nil? ? nil : session[:lesson]["activity"]
    @slot = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?) ? nil : session[:lesson]["lesson_time"]["slot"]
    @date = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?)  ? nil : session[:lesson]["lesson_time"]["date"]
    @lesson_time = @lesson.lesson_time
  end

  def new_request
    puts "!!! processing instructor request; Session variable is: #{session[:lesson]}"
    @lesson = Lesson.new
    @promo_location = session[:lesson].nil? ? nil : session[:lesson]["requested_location"]
    @activity = session[:lesson].nil? ? nil : session[:lesson]["activity"]
    @slot = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?) ? nil : session[:lesson]["lesson_time"]["slot"]
    @date = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?)  ? nil : session[:lesson]["lesson_time"]["date"]
    @instructor_requested = Instructor.find(params[:id]).id
    @lesson_time = @lesson.lesson_time
    render 'new'
  end

  def create
    if params["commit"] == "Book Lesson"
      create_lesson_and_redirect
    else
      session[:lesson] = params[:lesson]
      redirect_to '/browse'
    end
  end

  def complete
    @lesson = Lesson.find(params[:id])
    @lesson_time = @lesson.lesson_time
    @state = 'booked'
    flash.now[:notice] = "You're almost there! We just need a few more details."
    flash[:complete_form] = 'TRUE'
  end

  def edit
    @lesson = Lesson.find(params[:id])
    @lesson_time = @lesson.lesson_time
    @state = @lesson.instructor ? 'pending instructor' : 'booked'
  end

  def confirm_reservation
    @lesson = Lesson.find(params[:id])
    if @lesson.deposit_status != 'confirmed'
        @amount = @lesson.price.to_i
          customer = Stripe::Customer.create(
            :email => params[:stripeEmail],
            :source  => params[:stripeToken]
          )
          charge = Stripe::Charge.create(
            :customer    => customer.id,
            :amount      => @amount*100,
            :description => 'Lesson reservation deposit',
            :currency    => 'usd'
          )
        @lesson.deposit_status = 'confirmed'
        @lesson.state = 'booked'
        puts "!!!!!About to save state & deposit status after processing lessons#update"
        @lesson.save
      GoogleAnalyticsApi.new.event('lesson-requests', 'deposit-submitted', params[:ga_client_id])
      LessonMailer.send_lesson_request_notification(@lesson).deliver
      flash[:notice] = 'Thank you, your lesson request was successful. You will receive an email notification when your instructor confirmed your request. If it has been more than an hour since your request, please email support@snowschoolers.com.'
      flash[:conversion] = 'TRUE'
      puts "!!!!!!!! Lesson deposit successfully charged"
    end
    respond_with @lesson
  end

  def update
    @lesson = Lesson.find(params[:id])
    @original_lesson = @lesson.dup
    @lesson.assign_attributes(lesson_params)
    @lesson.lesson_time = @lesson_time = LessonTime.find_or_create_by(lesson_time_params)
    @lesson.requester = current_user
    if @lesson.guest_email && @lesson.requester.nil?
      User.create!({
        email: @lesson.guest_email,
        password: 'homewood_temp_2016',
        user_type: "Student",
        name: "#{@lesson.guest_email}"
        })
      @lesson.requester_id = User.last.id
    end
    unless @lesson.deposit_status == 'confirmed'
      @lesson.state = 'ready_to_book'
    end
    if @lesson.save
      GoogleAnalyticsApi.new.event('lesson-requests', 'full_form-updated', params[:ga_client_id])
      @user_email = current_user ? current_user.email : "unknown"
      LessonMailer.notify_admin_lesson_full_form_updated(@lesson, @user_email).deliver
      send_lesson_update_notice_to_instructor
    else
      determine_update_state
    end
    respond_with @lesson
  end

  def show
    @lesson = Lesson.find(params[:id])
    check_user_permissions
    # if @lesson.state == "waiting_for_payment"
    #   @transaction = Transaction.new
    # end
  end

  def destroy
    @lesson = Lesson.find(params[:id])
    @lesson.update(state: 'canceled')
    send_cancellation_email_to_instructor
    flash[:notice] = 'Your lesson has been canceled.'
    redirect_to root_path
  end

  def set_instructor
    @lesson = Lesson.find(params[:id])
    @lesson.instructor_id = current_user.instructor.id
    @lesson.state = 'confirmed'
    if @lesson.save
    LessonAction.create!({
      lesson_id: @lesson.id,
      instructor_id: current_user.instructor.id,
      action: "Accept"
      })
    LessonMailer.send_lesson_confirmation(@lesson).deliver
    @lesson.send_sms_to_requester
    redirect_to @lesson
    else
     redirect_to @lesson, notice: "Error: could not accept lesson. #{@lesson.errors.full_messages}"
    end
  end

  def decline_instructor
    @lesson = Lesson.find(params[:id])
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
    # LessonMailer.send_lesson_confirmation(@lesson).deliver
    redirect_to @lesson
  end

  def remove_instructor
    puts "the params are {#{params}"
    @lesson = Lesson.find(params[:id])
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
    @lesson = Lesson.find(params[:id])
    @lesson.state = 'finalizing'
    @lesson.save
    redirect_to @lesson
  end

  def confirm_lesson_time
    @lesson = Lesson.find(params[:id])
    if valid_duration_params?
      @lesson.update(lesson_params.merge(state: 'waiting for payment'))
      @lesson.state = @lesson.valid? ? 'waiting for payment' : 'confirmed'
      @lesson.send_sms_to_requester
      LessonMailer.send_payment_email_to_requester(@lesson).deliver
    end
    respond_with @lesson, action: :show
  end

  private

  def valid_duration_params?
     if params[:lesson][:actual_start_time].length == 0  || params[:lesson][:actual_end_time].length == 0
      flash[:alert] = "Please confirm start & end time, as well as lesson duration."
      return false
    else
      session[:lesson] = params[:lesson]
      return true
    end
  end

  def validate_new_lesson_params
    if params[:lesson].nil? || params[:lesson][:requested_location].to_i < 1 || params[:lesson][:lesson_time][:date].length < 10
      flash[:alert] = "Please first select a location and date."
      redirect_to new_lesson_path
    else
      session[:lesson] = params[:lesson]
    end
  end

  def save_lesson_params_and_redirect
    # if current_user.nil?
    #   session[:lesson] = params[:lesson]
    #   flash[:alert] = 'You need to sign in or sign up before continuing.'
    #   # flash[:notice] = "The captured params are #{params[:lesson]}"
    #   redirect_to new_user_registration_path and return
    # elsif params["commit"] != "Book Lesson"
    #   session[:lesson] = params[:lesson]
    # end
      validate_new_lesson_params
  end

  def create_lesson_from_session
    return unless current_user && session[:lesson]
    if params["commit"] == "Book Lesson"
      create_lesson_and_redirect
    else
      # session[:lesson] = params[:lesson]
      # puts "!!!!! params are: #{params[:lesson]}"
      # debugger
      redirect_to '/browse'
    end
  end

  def create_lesson_and_redirect
    @lesson = Lesson.new(lesson_params)
    @lesson.requester = current_user
    @lesson.lesson_time = @lesson_time = LessonTime.find_or_create_by(lesson_time_params)
    if @lesson.save
      redirect_to complete_lesson_path(@lesson)
      GoogleAnalyticsApi.new.event('lesson-requests', 'request-initiated', params[:ga_client_id])
      @user_email = current_user ? current_user.email : "unknown"
      LessonMailer.notify_admin_lesson_request_begun(@lesson, @user_email).deliver
      else
        @activity = session[:lesson].nil? ? nil : session[:lesson]["activity"]
        @slot = session[:lesson].nil? ? nil : session[:lesson]["lesson_time"]["slot"]
        @date = session[:lesson].nil? ? nil : session[:lesson]["lesson_time"]["date"]
        render 'new'
    end
  end

  def send_cancellation_email_to_instructor
    if @lesson.instructor.present?
      LessonMailer.send_cancellation_email_to_instructor(@lesson).deliver
    end
  end

  def send_instructor_cancellation_emails
    LessonMailer.send_lesson_request_to_new_instructors(@lesson, @lesson.instructor).deliver if @lesson.available_instructors?
    LessonMailer.inform_requester_of_instructor_cancellation(@lesson, @lesson.available_instructors?).deliver
    LessonMailer.send_cancellation_confirmation(@lesson).deliver
  end

  def send_lesson_update_notice_to_instructor
    return unless @lesson.deposit_status == 'confirmed'
    if @lesson.instructor.present?
      changed_attributes = @lesson.get_changed_attributes(@original_lesson)
      return unless changed_attributes.any?
      LessonMailer.send_lesson_update_notice_to_instructor(@original_lesson, @lesson, changed_attributes).deliver
    end
  end

  def check_user_permissions
    return unless @lesson.guest_email.nil?
    unless (current_user && current_user == @lesson.requester || (current_user && current_user.instructor && current_user.instructor.status == "Active") || @lesson.requester.nil? || (current_user.nil? && @lesson.requester.email == "brian@snowschoolers.com") || (current_user && (current_user.user_type == "Ski Area Partner" || current_user.user_type == "Snow Schoolers Employee"))   )
      puts "!!!!!!! INSUFFICIENT PERMISSIONS"
      flash[:alert] = "You do not have access to this page."
      redirect_to root_path
    end
  end

  def determine_update_state
    @lesson.state = 'new' unless params[:lesson][:terms_accepted] == '1'
    if @lesson.deposit_status == 'confirmed'
      flash.now[:notice] = "Your lesson deposit has been recorded, but your lesson reservation is incomplete. Please fix the fields below and resubmit."
      @lesson.state = 'booked'
    end
    @lesson.save
    @state = params[:lesson][:state]
  end

  def lesson_params
    params.require(:lesson).permit(:activity, :phone_number, :requested_location, :state, :student_count, :gear, :lift_ticket_status, :objectives, :duration, :ability_level, :start_time, :actual_start_time, :actual_end_time, :actual_duration, :terms_accepted, :deposit_status, :public_feedback_for_student, :private_feedback_for_student, :instructor_id, :focus_area, :requester_id, :guest_email, :how_did_you_hear,
      students_attributes: [:id, :name, :age_range, :gender, :relationship_to_requester, :lesson_history, :requester_id, :most_recent_experience, :most_recent_level, :other_sports_experience, :experience, :_destroy])
  end

  def lesson_time_params
    params[:lesson].require(:lesson_time).permit(:date, :slot)
  end
end
