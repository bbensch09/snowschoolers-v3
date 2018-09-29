class LessonMailer < ActionMailer::Base
  include ApplicationHelper
  include Resque::Mailer
  default from: 'SnowSchoolers.com <info@snowschoolers.com>' #cc: "Adam Garon <#{ENV['SUPERVISOR_EMAIL']}>"
  before_filter :log_mailer_action

  def log_mailer_action
    puts "!!! logging action mailer before filter. currently does nothing"
    puts "!!! email notification status is = #{email_status}"
    puts "!!! email notification status is = #{sms_status}"
  end

  def track_apply_visits(email="Unknown user")
      @email = email
      mail(to: 'brian@snowschoolers.com', subject: "Pageview at /apply - #{email}.")
  end

  def notify_admin_preseason_request(request)
      @location_name = request.name
      mail(to: 'brian@snowschoolers.com', subject: "New Preseason Resort request - #{@location_name}.")
  end

  def notify_admin_lesson_request_begun(lesson,email)
      @lesson = lesson
      @user_email = email
      mail(to: 'brian@snowschoolers.com', subject: "New Lesson Request begun - #{@lesson.date} - #{@lesson.guest_email}.")
  end

  def notify_admin_lesson_full_form_updated(lesson_id)
      @lesson = Lesson.find(lesson_id)
      @user_email = @lesson.guest_email ? @lesson.guest_email : @lesson.requester.email
      return if @lesson.email_notifications_status == 'disabled'
      mail(to: 'notify@snowschoolers.com', cc: "Adam Garon <#{ENV['SUPERVISOR_EMAIL']}>", subject: "Lesson Request complete, ready for deposit - #{@lesson.date.strftime("%b %-d")}.")
  end

  def notify_admin_beta_user(beta_user)
      @beta_user = beta_user
      mail(to: 'brian@snowschoolers.com', subject: "New Beta User - #{@beta_user.email}.")
  end

  def notify_sumo_success(email="Unknown Sumo User")
      @email = email
      mail(to: 'brian@snowschoolers.com', subject: "Sumo Success - #{@email} has subscribed.")
  end

  def notify_comparison_shopping_referral(product, current_user, unique_id)
      @product = product
      @current_user = current_user
      @unique_id = unique_id
      mail(to: 'brian@snowschoolers.com', subject: "tracked referral - #{@product.name} @ #{@product.location.name}")
  end

  def notify_homewood_pass_referral(current_user,unique_id)
      @current_user = current_user
      @unique_id = unique_id
      mail(to: 'brian@snowschoolers.com', subject: "homewood season pass tracked referral")
  end

  def notify_liftopia_referral
      mail(to: 'brian@snowschoolers.com', subject: "liftopia referral click-thru")
  end

  def notify_mountain_collective_referral
      mail(to: 'brian@snowschoolers.com', subject: "Mountain Collective referral click-thru")
  end

  def notify_skibutlers_referral
      mail(to: 'brian@snowschoolers.com', subject: "Ski Butlers referral click-thru")
  end
  
  def notify_sportsbasement_referral
      mail(to: 'brian@snowschoolers.com', subject: "Sports Basement referral click-thru")
  end

  def notify_tahoedaves_referral
      mail(to: 'brian@snowschoolers.com', subject: "Tahoe Daves's referral click-thru")
  end

  def notify_resort_referral(resort,user)
      @resort = resort
      @user = user
      mail(to: 'brian@snowschoolers.com', subject: "#{@user} has clicked thru to #{@resort}'s website")
  end

  def notify_homewood_learn_to_ski_referral
      mail(to: 'brian@snowschoolers.com', subject: "Homewood LTS shopping comparison referral click-thru")
  end
  
  def notify_homewood_group_lesson_referral(type)
      @type = type
      mail(to: 'brian@snowschoolers.com', subject: "Homewood #{@type} group lessons referral click-thru")
  end

  def notify_jackson_promo_user(beta_user)
      @beta_user = beta_user
      mail(to: 'brian@snowschoolers.com', subject: "Jackson Hole interested user - #{@beta_user.email}.")
  end

  def notify_powder_promo(beta_user)
      @beta_user = beta_user
      mail(to: 'brian@snowschoolers.com', subject: "Powder Lesson interested user - #{@beta_user.email}.")
  end

  def notify_package_promo(beta_user)
      @beta_user = beta_user
      mail(to: 'brian@snowschoolers.com', subject: "Learn to Ski Packages request - #{@beta_user.email}.")
  end

  def notify_march_madness_signup(beta_user)
      @beta_user = beta_user
      mail(to: 'brian@snowschoolers.com', subject: "March Madness signup - #{@beta_user.email}.")
  end

  def notify_team_offsite(beta_user)
      @beta_user = beta_user
      mail(to: 'brian@snowschoolers.com', subject: "Team Offsite signup - #{@beta_user.email}.")
  end

  def notify_beginner_concierge(beta_user)
      @beta_user = beta_user
      mail(to: 'brian@snowschoolers.com', subject: "Concierge request - #{@beta_user.email}.")
  end

  def notify_admin_sms_logs(lesson,recipient,body,instructor_id=nil)
      @lesson = lesson
      @recipient = recipient
      @body = body
      if instructor_id
        @instructor_id = instructor_id
        @instructor = Instructor.find(instructor_id)
        @instructor_name = @instructor ? @instructor.name : 'not provided'
      end
      mail(to: 'brian@snowschoolers.com', cc: "Adam Garon <#{ENV['SUPERVISOR_EMAIL']}>", subject: "SMS sent to #{@recipient}")
  end

  def send_admin_notify_invalid_phone_number(lesson)
      @lesson = lesson
      mail(to: 'brian@snowschoolers.com', subject: "Alert - Failed to send SMSto #{@lesson.phone_number}")
  end

  def application_begun(email="Unknown user",first_name="John", last_name="Doe")
      @email = email
      @name = first_name + last_name
      mail(to: 'brian@snowschoolers.com', subject: "Application begun - #{email} has entered their email.")
  end

  def new_user_signed_up(user)
    @user = user
    mail(to: 'brian@snowschoolers.com', subject: "A new user has registered for Snow Schoolers")
  end

  def new_instructor_application_received(instructor)
    @instructor = instructor
    mail(to: 'info@snowschoolers.com', cc: 'brian@snowschoolers.com', subject: "Submitted Application: #{@instructor.username} has applied to join Snow Schoolers")
  end

  def send_new_instructor_application_confirmation(instructor)
    @instructor = instructor
    mail(to: @instructor.username, cc: 'info@snowschoolers.com', subject: "Thanks for applying to Snow Schoolers -- please schedule your interview!")
  end

  def new_hta_application_received(instructor)
    @instructor = instructor
    mail(to: 'info@snowschoolers.com', cc: 'brian@snowschoolers.com', subject: "Submitted HTA Application: #{@instructor.username} has applied to join Snow Schoolers")
  end

  def send_hta_application_confirmation(instructor)
    @instructor = instructor
    mail(to: @instructor.username, cc: 'info@snowschoolers.com', subject: "Thanks for applying to our upcoming Accelerated Instructor Certification Program -- we'll be in touch!")
  end

  def new_homewood_application_received(applicant)
    @applicant = applicant
    mail(to: 'brian+marc@snowschoolers.com', cc:'brian@snowschoolers.com', subject: "Submitted Application: #{@applicant.email} has applied to join Homewood")
  end

  def new_review_submitted(review)
    @review = review
    return if @review.lesson.email_notifications_status == 'disabled'
    mail(to: 'brian@snowschoolers.com', subject: "Review submitted: #{@review.reviewer.email} has provided their review")
  end

  def instructor_status_activated(instructor)
    @instructor = instructor
    mail(to: @instructor.user.email, cc: "brian@snowschoolers.com, Adam Garon <#{ENV['SUPERVISOR_EMAIL']}>", subject: "Your Snow Schoolers instructor status is now Active!")
  end

  def subscriber_sign_up(beta_user)
    @beta_user = beta_user
    mail(to: 'brian@snowschoolers.com', subject: "Someone has subscribed to the Snow Schoolers mailing list")
  end

  def send_lesson_request_to_instructors(lesson, excluded_instructor=nil)
    @lesson = lesson
    available_instructors = (lesson.available_instructors - [excluded_instructor])
    @available_instructors = []
    #select only the first instructor in the array that is available to email.
    # instructors_to_email = available_instructors[0...1]
    #load email addresses for instructors to email
    available_instructors.each do |instructor|
      if instructor.user 
        @available_instructors << instructor.user.email
      end
    end
    return if @lesson.email_notifications_status == 'disabled'
    mail(to: 'notify@snowschoolers.com', cc: "Adam Garon <#{ENV['SUPERVISOR_EMAIL']}>", bcc: @available_instructors, subject: "You have a new Snow Schoolers lesson request on #{@lesson.date.strftime("%b %-d")}")
  end

  def send_lesson_request_to_new_instructors(lesson, excluded_instructor=nil)
    @lesson = lesson
    available_instructors = (lesson.available_instructors - [excluded_instructor])
    @available_instructors = []
    available_instructors.each do |instructor|
      if instructor.user 
        @available_instructors << instructor.user.email
      end
    end
    return if @lesson.email_notifications_status == 'disabled'
    mail(to: 'notify@snowschoolers.com', cc: "Adam Garon <#{ENV['SUPERVISOR_EMAIL']}>, notify@snowschoolers.com", bcc: @available_instructors, subject: 'A previous instructor canceled - can you help with this lesson request?')
  end

  # notification when instructor cancels
  def send_cancellation_confirmation(canceling_instructor,lesson)
    @lesson = lesson
    @canceling_instructor = canceling_instructor
    return if @lesson.email_notifications_status == 'disabled'
    mail(to: @canceling_instructor, cc:'notify@snowschoolers.com, adam@snowschoolers.com', subject: 'You have canceled your Snow Schoolers lesson')
  end

  def send_lesson_hw_confirmation(lesson) #this gets sent after the instructor has accepted the lesson request.
    @lesson = lesson
    if @lesson.guest_email.nil?
      recipient = @lesson.requester.email
    else
      recipient = @lesson.guest_email
    end
    return if @lesson.email_notifications_status == 'disabled'
      mail(to: recipient, cc: "Adam Garon <#{ENV['SUPERVISOR_EMAIL']}>, notify@snowschoolers.com", bcc:@lesson.instructor.user.email, subject: "Your Snow Schoolers lesson on #{@lesson.date.strftime("%b %-d")} with #{@lesson.instructor.name} is confirmed!")
  end

  def send_lesson_gb_confirmation(lesson) #this gets sent after the instructor has accepted the lesson request.
    @lesson = lesson
    if @lesson.guest_email.nil?
      recipient = @lesson.requester.email
    else
      recipient = @lesson.guest_email
    end
    return if @lesson.email_notifications_status == 'disabled'
      mail(to: recipient, cc: "Adam Garon <#{ENV['SUPERVISOR_EMAIL']}>, notify@snowschoolers.com", bcc:@lesson.instructor.user.email, subject: "Instructor Confirmation: your Snow Schoolers lesson on #{@lesson.date.strftime("%b %-d")} with #{@lesson.instructor.name} is confirmed!")
  end

  def send_day_before_reminder_email(lesson_id)
    @lesson = Lesson.find(lesson_id)
    student_email = @lesson.contact_email
    instructor_email = @lesson.instructor ? @lesson.instructor.email : "notify@snowschoolers.com"
    instructor_name = @lesson.instructor ? @lesson.instructor.first_name : "Snow Schoolers"
    return if @lesson.email_notifications_status == 'disabled'
    mail(to: student_email, bcc: "SnowSchoolers.com <notify@snowschoolers.com>, Adam Garon <#{ENV['SUPERVISOR_EMAIL']}>", cc:instructor_email, subject: "Reminder: #{@lesson.activity} lesson tomorrow with #{instructor_name} at #{@lesson.location.name} - #{@lesson.slot}")
  end  

  def send_lesson_request_notification(lesson)
    @lesson = lesson
    return if @lesson.email_notifications_status == 'disabled'
    if @lesson.guest_email.nil? || @lesson.guest_email == ""
      mail(to: @lesson.requester.email,  cc: "Adam Garon <#{ENV['SUPERVISOR_EMAIL']}>, notify@snowschoolers.com", subject: "Reservation Confirmation: Thanks for booking with Snow Schoolers for #{@lesson.date.strftime("%b %-d")}")
    else
      mail(to: @lesson.guest_email,  cc: "Adam Garon <#{ENV['SUPERVISOR_EMAIL']}>, notify@snowschoolers.com", subject: "Reservation Confirmation: Thanks for booking with Snow Schoolers for  for #{@lesson.date.strftime("%b %-d")}")
    end
  end

  def send_promo_redemption_notification(lesson)
    @lesson = lesson
    mail(to: @lesson.requester.email,  cc: "Adam Garon <#{ENV['SUPERVISOR_EMAIL']}>, notify@snowschoolers.com", subject: "The promo code #{@lesson.promo_code.promo_code} has been redeemed for a lesson on #{@lesson.date.strftime("%b %-d")}")
  end

  def send_lesson_update_notice_to_instructor(original_lesson, updated_lesson, changed_attributes)
    @original_lesson = original_lesson
    @updated_lesson = updated_lesson
    @changed_attributes = changed_attributes
    return if @lesson.email_notifications_status == 'disabled'
    mail(to: @updated_lesson.instructor.user.email, cc:'notify@snowschoolers.com', subject: 'One of your Snow Schoolers lesson has been updated')
  end

  # notification when client cancels
  def send_cancellation_email_to_instructor(lesson)
    @lesson = lesson
    return if @lesson.email_notifications_status == 'disabled'
    mail(to: @lesson.instructor.user.email, cc:'notify@snowschoolers.com', bcc: @lesson.requester.email, subject: 'One of your Snow Schoolers lessons has been canceled')
  end

  def inform_requester_of_instructor_cancellation(lesson, available_instructors)
    @lesson = lesson
    @available_instructors = available_instructors
    return if @lesson.email_notifications_status == 'disabled'
    mail(to: @lesson.requester.email, cc:'notify@snowschoolers.com', subject: 'Your Snow Schoolers lesson has been canceled')
  end

  def send_payment_email_to_requester(lesson_id)
    @lesson = Lesson.find(lesson_id)
    return if @lesson.email_notifications_status == 'disabled'
    if @lesson.guest_email.nil?
      mail(to: @lesson.requester.email, cc:'notify@snowschoolers.com', subject: 'Please complete your Snow Schoolers online experience!')
    else
      mail(to: @lesson.guest_email, cc:'notify@snowschoolers.com', subject: 'Please complete your Snow Schoolers online experience!')
    end
  end
end
