class Lesson < ActiveRecord::Base
  belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'
  belongs_to :instructor
  belongs_to :lesson_time
  has_many :students
  has_one :review
  has_many :transactions
  has_many :lesson_actions
  accepts_nested_attributes_for :students, reject_if: :all_blank, allow_destroy: true

  validates :requested_location, :lesson_time, presence: true
  validates :phone_number, :objectives,
            presence: true, on: :update
  # validates :duration, :start_time, presence: true, on: :update
  # validates :gear, inclusion: { in: [true, false] }, on: :update
  # validates :ability_level, presence: true
  validates :terms_accepted, inclusion: { in: [true], message: 'must accept terms' }, on: :update
  validates :actual_start_time, :actual_end_time, presence: true, if: :just_finalized?
  validate :instructors_must_be_available, unless: :no_instructors_post_instructor_drop?, on: :create
  # validate :requester_must_not_be_instructor, on: :create
  validate :lesson_time_must_be_valid
  validate :student_exists, on: :update

  # MUST UNCOMMENT LESSON REQUEST METHOD BELOW TO ENABLE EMAILS & TWILIO
  after_update :send_lesson_request_to_instructors
  before_save :calculate_actual_lesson_duration, if: :just_finalized?

  def date
    lesson_time.date
  end

  def slot
    lesson_time.slot
  end

  def product
    Product.where(location_id:self.location.id, name:self.lesson_time.slot,calendar_period:self.location.calendar_status).first
  end

  def tip
    self.transactions.last.final_amount - self.transactions.last.base_amount
  end

  def location
    Location.find(self.requested_location.to_i)
  end

  def active?
    active_states = ['new', 'booked', 'confirmed','pending instructor', 'pending requester','']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    active_states.include?(state)
  end

  def active_today?
    active_states = ['confirmed','seeking replacement instructor','pending instructor', 'pending requester','Lesson Complete','waiting for payment','waiting for review','finalizing']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    return true if self.date == Date.today && active_states.include?(state)
  end

  def active_next_7_days?
    active_states = ['new','booked','confirmed','seeking replacement instructor','pending instructor', 'pending requester','Lesson Complete','waiting for payment','waiting for review','finalizing']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    return true if active_states.include?(state) && self.date <= Date.today + 7 && self.date > Date.today
  end

  def confirmable?
    confirmable_states = ['booked', 'pending instructor', 'pending requester','seeking replacement instructor']
    confirmable_states.include?(state) && self.available_instructors.any?
  end

  def completable?
    self.state == 'confirmed'
  end

   def new?
    state == 'new'
  end

  def canceled?
    state == 'canceled'
  end

  def pending_instructor?
    state == 'pending instructor'
  end

  def pending_requester?
    state == 'pending requester'
  end

  def finalizing?
    state == 'finalizing'
  end

  def waiting_for_payment?
    state == 'waiting for payment'
  end

  def waiting_for_review?
    state == 'Payment complete, waiting for review.'
  end

  def completed?
    active_states = ['waiting for payment','Payment complete, waiting for review.','Lesson Complete']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    active_states.include?(state)
  end

  def payment_complete?
    state == 'Payment complete, waiting for review.' || state == 'Lesson Complete'
  end

  def instructor_accepted?
    LessonAction.where(action:"Accept", lesson_id: self.id).any?
  end

  def self.visible_to_instructor?(instructor)
      lessons = []
      assigned_to_instructor = Lesson.where(instructor_id:instructor.id)
      available_to_instructor = Lesson.all.to_a.keep_if {|lesson| (lesson.confirmable? && lesson.instructor_id.nil? )}
      lessons = assigned_to_instructor + available_to_instructor
  end

  def declined_instructors
    decline_actions = LessonAction.where(action:"Decline", lesson_id: self.id)
    declined_instructors = []
    decline_actions.each do |action|
      declined_instructors << Instructor.find(action.instructor_id)
    end
    declined_instructors
  end


  def calculate_actual_lesson_duration
    start_time = Time.parse(actual_start_time)
    end_time = Time.parse(actual_end_time)
    self.actual_duration = (end_time - start_time)/3600
  end

  def just_finalized?
    waiting_for_payment?
  end

  def price
    product = Product.where(location_id:self.requested_location.to_i,name:self.lesson_time.slot).first
    if product.nil?
      return "Error - lesson price not found" #99 #default lesson price - temporary
    else
      return product.price
    end
  end

  # def price
  #   hourly_base = 75
  #   surge = 1
  #   hourly_price = hourly_base*surge
  #   if self.actual_duration.nil?
  #     if self.duration.nil?
  #         price = hourly_price * 2
  #       else
  #         price = self.duration * hourly_price
  #     end
  #   else
  #     price = self.actual_duration * hourly_price
  #   end
  # end

  def get_changed_attributes(original_lesson)
    lesson_changes = self.previous_changes
    lesson_time_changes = self.lesson_time.changes
    changed_attributes = lesson_changes.merge(lesson_time_changes)
    changed_attributes.reject { |attribute, change| ['updated_at', 'id', 'state', 'lesson_time_id'].include?(attribute) }
  end

  def kids_lesson?
    self.students.each do |student|
      return true if student.age_range == 'Under 10' || student.age_range == '11-17'
    end
    return false
  end

  def seniors_lesson?
    self.students.each do |student|
      return true if student.age_range == '51 and up'
    end
    return false
  end

  def level
    return false if self.students.nil?
    student_levels = []
    self.students.each do |student|
      #REFACTOR ALERT extract the 7th character from student experience level, which yields the level#, such as in 'Level 2 - wedge turns...'
      student_levels << student.most_recent_level[6].to_i
    end
    return student_levels.max
  end

  def available_instructors
    if self.instructor_id
        if  Lesson.instructors_with_calendar_blocks(self.lesson_time).include?(self.instructor)
          return []
        else
          return [self.instructor]
        end
    else
    resort_instructors = self.location.instructors
    # puts "!!!!!!! - Step #1 Filtered for location, found #{resort_instructors.count} instructors."
    if self.activity == 'Ski'
        wrong_sport = "Snowboard Instructor"
      else
        wrong_sport = "Ski Instructor"
    end
    active_resort_instructors = resort_instructors.where(status:'Active')
    # puts "!!!!!!! - Step #2 Filtered for active status, found #{active_resort_instructors.count} instructors."
    if self.activity == 'Ski' && self.level
      active_resort_instructors = active_resort_instructors.to_a.keep_if {|instructor| (instructor.ski_levels.any? && instructor.ski_levels.max.value >= self.level) }
    end
    if self.activity == 'Snowboard' && self.level
      active_resort_instructors = active_resort_instructors.to_a.keep_if {|instructor| (instructor.snowboard_levels.any? && instructor.snowboard_levels.max.value >= self.level )}
    end
    # puts "!!!!!!! - Step #3 Filtered for level, found #{active_resort_instructors.count} instructors."
    if kids_lesson?
      active_resort_instructors = active_resort_instructors.to_a.keep_if {|instructor| instructor.kids_eligibility == true }
      # puts "!!!!!!! - Step #3b Filtered for kids specialist, now have #{active_resort_instructors.count} instructors."
    end
    if seniors_lesson?
      active_resort_instructors = active_resort_instructors.to_a.keep_if {|instructor| instructor.seniors_eligibility == true }
      # puts "!!!!!!! - Step #3c Filtered for seniors specialist, now have #{active_resort_instructors.count} instructors."
    end
    wrong_sport_instructors = Instructor.where(sport: wrong_sport)
    already_booked_instructors = Lesson.booked_instructors(lesson_time)
    busy_instructors = Lesson.instructors_with_calendar_blocks(lesson_time)
    declined_instructors = []
    declined_actions = LessonAction.where(lesson_id: self.id, action:"Decline")
    declined_actions.each do |action|
      declined_instructors << Instructor.find(action.instructor_id)
    end
    # puts "!!!!!!! - Step #4a - eliminating #{wrong_sport_instructors.count} that teach the wrong sport."
    # puts "!!!!!!! - Step #4b - eliminating #{already_booked_instructors.count} that are already booked."
    # puts "!!!!!!! - Step #4c - eliminating #{declined_instructors.count} that have declined."
    # puts "!!!!!!! - Step #4d - eliminating #{busy_instructors.count} that are busy."
    available_instructors = active_resort_instructors - already_booked_instructors - declined_instructors - wrong_sport_instructors - busy_instructors
    # puts "!!!!!!! - Step #5 after all filters, found #{available_instructors.count} instructors."
    available_instructors = self.rank_instructors(available_instructors)
    return available_instructors
    end
  end

  def rank_instructors(available_instructors)
    puts "!!!!!!!ranking instructors now"
    if kids_lesson?
      available_instructors.sort! {|a,b| b.kids_score <=> a.kids_score }
      elsif seniors_lesson?
      available_instructors.sort! {|a,b| b.seniors_score <=> a.seniors_score }
      else
      available_instructors.sort! {|a,b| b.overall_score <=> a.overall_score }
    end
    return available_instructors
  end

  def available_instructors?
    available_instructors.any?
  end

  def self.find_lesson_times_by_requester(user)
    self.where('requester_id = ?', user.id).map { |lesson| lesson.lesson_time }
  end

  def self.instructors_with_calendar_blocks(lesson_time)
    if lesson_time.slot == 'Full Day'
      calendar_blocks = self.find_all_calendar_blocks_in_day(lesson_time)
    else
      calendar_blocks = self.find_calendar_blocks(lesson_time)
    end
    blocked_instructors =[]
    calendar_blocks.each do |block|
      blocked_instructors << Instructor.find(block.instructor_id)
    end
    return blocked_instructors
  end

  def self.find_calendar_blocks(lesson_time)
    same_slot_blocks = CalendarBlock.where(lesson_time_id:lesson_time.id, status:'Block this time slot')
    overlapping_full_day_blocks = self.find_full_day_blocks(lesson_time)
    return same_slot_blocks + overlapping_full_day_blocks
  end

  def self.find_full_day_blocks(lesson_time)
    full_day_lesson_time = LessonTime.find_by_date_and_slot(lesson_time.date,'Full Day')
    return [] if full_day_lesson_time.nil?
    full_day_blocks = []
    blocks_on_same_day = CalendarBlock.where(lesson_time_id:full_day_lesson_time.id, status:'Block this time slot')
      blocks_on_same_day.each do |block|
        full_day_blocks << block
      end
    return full_day_blocks
  end

  def self.find_all_calendar_blocks_in_day(lesson_time)
    matching_lesson_times = LessonTime.where(date:lesson_time.date)
    return [] if matching_lesson_times.nil?
    calendar_blocks = []
    matching_lesson_times.each do |lt|
      blocks_at_lt = CalendarBlock.where(lesson_time_id:lt.id)
      blocks_at_lt.each do |block|
        calendar_blocks << block
      end
    end
    return calendar_blocks
  end

  def self.booked_instructors(lesson_time)
    # puts "checking for booked instructors on #{lesson_time.date} during the #{lesson_time.slot} slot"
    if lesson_time.slot == 'Full Day'
      booked_lessons = self.find_all_booked_lessons_in_day(lesson_time)
    else
      booked_lessons = self.find_booked_lessons(lesson_time)
    end
    # puts "There is/are #{booked_lessons.count} lesson(s) already booked at this time."
    booked_instructors = []
    booked_lessons.each do |lesson|
      booked_instructors << lesson.instructor
    end
    return booked_instructors
  end

  def self.find_booked_lessons(lesson_time)
    lessons_in_same_slot = Lesson.where('lesson_time_id = ?', lesson_time.id)
    overlapping_full_day_lessons = self.find_full_day_lessons(lesson_time)
    return lessons_in_same_slot + overlapping_full_day_lessons
  end

  def self.find_full_day_lessons(full_day_lesson_time)
    return [] unless full_day_lesson_time = LessonTime.find_by_date_and_slot(full_day_lesson_time.date,'Full Day')
    booked_lessons = []
    lessons_on_same_day = Lesson.where("lesson_time_id=? AND instructor_id is not null",full_day_lesson_time.id)
      lessons_on_same_day.each do |lesson|
        booked_lessons << lesson
        # puts "added a booked lesson to the booked_lesson set"
      end
    # puts "After searching through the matching lesson times on this date, the booked lesson count on this day is now: #{booked_lessons.count}"
    return booked_lessons
  end

  def self.find_all_booked_lessons_in_day(full_day_lesson_time)
    matching_lesson_times = LessonTime.where("date=?",full_day_lesson_time.date)
    # puts "------there are #{matching_lesson_times.count} matched lesson times on this date."
    booked_lessons = []
    matching_lesson_times.each do |lt|
      lessons_at_lt = Lesson.where("lesson_time_id=? AND instructor_id is not null",lt.id)
      lessons_at_lt.each do |lesson|
        booked_lessons << lesson
      end
    end
    # puts "After searching through the matching lesson times on this date, the booked lesson count on this day is now: #{booked_lessons.count}"
    return booked_lessons
  end

  def send_sms_to_instructor
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      recipient = self.available_instructors.any? ? self.available_instructors.first.phone_number : "4083152900"
      case self.state
        when 'new'
          body = "A lesson booking was begun and not finished. Please contact an admin or email info@snowschoolers.com if you intended to complete the lesson booking."
        when 'booked'
          body = "#{self.available_instructors.first.first_name}, You have a new lesson request from #{self.requester.name} at #{self.product.start_time} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name}. Are you available? Please visit #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm."
        when 'seeking replacement instructor'
          body = "We need your help! Another instructor unfortunately had to cancel. Are you available to teach #{self.requester.name} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name} at #{self.product.start_time}? Please visit #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm."
        when 'pending instructor'
          body =  "#{self.available_instructors.first.first_name}, There has been a change in your previously confirmed lesson request. #{self.requester.name} would now like their lesson to be at #{self.product.start_time} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name}. Are you still available? Please visit #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm."
        when 'Payment complete, waiting for review.'
          body = "#{self.requester.name} has completed payment for their lesson and you've received a tip of $#{(self.tip.to_i)}. Great work!"
      end
      @client = Twilio::REST::Client.new account_sid, auth_token
          @client.account.messages.create({
          :to => recipient,
          :from => "#{snow_schoolers_twilio_number}",
          :body => body
      })
      send_reminder_sms
      puts "!!!!! - reminder SMS has been scheduled"
  end

  def send_reminder_sms
    return if self.state == 'confirmed' || (Time.now - LessonAction.last.created_at) < 20
    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_AUTH']
    snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
    recipient = self.available_instructors.any? ? self.available_instructors.first.phone_number : "4083152900"
    body = "#{self.available_instructors.first.first_name}, it has been over 5 minutes and you have not accepted or declined this request. We are now making this lesson available to other instructors. You may still visit #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm the lesson."
    @client = Twilio::REST::Client.new account_sid, auth_token
          @client.account.messages.create({
          :to => recipient,
          :from => "#{snow_schoolers_twilio_number}",
          :body => body
      })
      puts "!!!!! - reminder SMS has been sent"
      send_sms_to_all_other_instructors
  end
  handle_asynchronously :send_reminder_sms, :run_at => Proc.new {300.seconds.from_now }

  def send_sms_to_all_other_instructors
    recipients = self.available_instructors
    if recipients.count < 2
      @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']
          @client.account.messages.create({
          :to => "408-315-2900",
          :from => ENV['TWILIO_NUMBER'],
          :body => "ALERT - #{self.available_instructors.first.name} is the only instructor available and they have not responded after 10 minutes. No other instructors are available to teach #{self.requester.name} at #{self.product.start_time} on #{self.lesson_time.date} at #{self.location.name}."
      })
    end
    # identify recipients to be notified as all available instructors except for the first instructor, who has been not responsive
    recipients[1..-1].each do |instructor|
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      body = "#{instructor.first_name}, we have a customer who is eager to find an instructor. #{self.requester.name} wants a lesson at #{self.product.start_time} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name}. Are you available? The lesson is now available to the first instructor that claims it by visiting #{ENV['HOST_DOMAIN']}/lessons/#{self.id} and accepting the request."
      @client = Twilio::REST::Client.new account_sid, auth_token
            @client.account.messages.create({
            :to => instructor.phone_number,
            :from => "#{snow_schoolers_twilio_number}",
            :body => body
        })
    end
  end
  # handle_asynchronously :send_sms_to_all_other_instructors, :run_at => Proc.new {5.seconds.from_now }

  def send_sms_to_requester
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      recipient = self.phone_number
      case self.state
        when 'confirmed'
        body = "Congrats! Your Snow Schoolers lesson has been confirmed. #{self.instructor.name} will be your instructor at #{self.location.name} on #{self.lesson_time.date.strftime("%b %d")} at #{self.product.start_time}. Please check your email for more details about meeting location & to review your pre-lesson checklist."
        when 'seeking replacement instructor'
        body = "Bad news! Your instructor has unfortunately had to cancel your lesson. Don't worry, we are finding you a new instructor right now."
        when 'waiting for payment'
        body = "We hope you had a great lesson today with #{self.instructor.name}! You may now complete your lesson payment and leave a quick review for your instructor by visiting #{ENV['HOST_DOMAIN']}/lessons/#{self.id}. Thanks for using Snow Schoolers!"
      end
      @client = Twilio::REST::Client.new account_sid, auth_token
          @client.account.messages.create({
          :to => recipient,
          :from => "#{snow_schoolers_twilio_number}",
          :body => body
      })
  end

  def send_sms_to_admin
      @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']
          @client.account.messages.create({
          :to => "408-315-2900",
          :from => ENV['TWILIO_NUMBER'],
          :body => "ALERT - no instructors are available to teach #{self.requester.name} at #{self.product.start_time} on #{self.lesson_time.date} at #{self.location.name}. The last person to decline was #{Instructor.find(LessonAction.last.instructor_id).username}."
      })
  end

  def send_sms_to_admin_1to1_request_failed
      @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']
          @client.account.messages.create({
          :to => "408-315-2900",
          :from => ENV['TWILIO_NUMBER'],
          :body => "ALERT - A private 1:1 request was made and declined. #{self.requester.name} had requested #{self.instructor.name} but they are unavailable at #{self.product.start_time} on #{self.lesson_time.date} at #{self.location.name}."
      })
  end

  private

  def instructors_must_be_available
    errors.add(:instructor, " not available at that time and location. Email info@snowschoolers.com to be notified if we have any instructors that become available.") unless available_instructors.any?
  end

  def requester_must_not_be_instructor
    errors.add(:instructor, "cannot request a lesson") unless self.requester.instructor.nil?
  end

  def lesson_time_must_be_valid
    errors.add(:lesson_time, "invalid") unless lesson_time.valid?
  end

  def student_exists
    errors.add(:students, "count must be greater than zero") unless students.any?
  end

  def send_lesson_request_to_instructors
    #currently testing just to see whether lesson is active and deposit has gone through successfully.
    #need to replace with logic that tests whether lesson is newly complete, vs. already booked, etc.
    if self.active? && self.confirmable? && self.state != "pending instructor" #&& self.deposit_status == 'verified'
      LessonMailer.send_lesson_request_to_instructors(self).deliver
      self.send_sms_to_instructor
    elsif self.available_instructors.any? == false
      self.send_sms_to_admin
    end
  end

  def no_instructors_post_instructor_drop?
    pending_requester?
  end
end
