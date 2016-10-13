class Lesson < ActiveRecord::Base
  belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'
  belongs_to :instructor
  belongs_to :lesson_time
  has_many :students
  has_one :transaction
  has_many :lesson_actions
  accepts_nested_attributes_for :students, reject_if: :all_blank, allow_destroy: true

  validates :requested_location, :lesson_time, presence: true
  validates :phone_number, :objectives, :ability_level,
            presence: true, on: :update
  # validates :duration, :start_time, presence: true, on: :update
  # validates :gear, inclusion: { in: [true, false] }, on: :update
  validates :terms_accepted, inclusion: { in: [true], message: 'must accept terms' }, on: :update
  validates :actual_start_time, :actual_end_time, presence: true, if: :just_finalized?
  validate :instructors_must_be_available, unless: :no_instructors_post_instructor_drop?, on: :create
  validate :requester_must_not_be_instructor, on: :create
  validate :lesson_time_must_be_valid
  validate :student_exists, on: :update

  after_update :send_lesson_request_to_instructors
  before_save :calculate_actual_lesson_duration, if: :just_finalized?

  def date
    lesson_time.date
  end

  def slot
    lesson_time.slot
  end

  def location
    Location.find(self.requested_location.to_i)
  end

  def completed?
    active_states = ['waiting_for_payment','Payment Complete']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    active_states.include?(state)
  end

  def active?
    active_states = ['new', 'booked', 'confirmed','pending instructor', 'pending requester','']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    active_states.include?(state)
  end

  def active_today?
    active_states = ['new', 'booked', 'confirmed','pending instructor', 'pending requester','']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    return true if self.date == Date.today
  end

  def active_next_7_days?
    active_states = ['new', 'booked', 'confirmed','pending instructor', 'pending requester','']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    return true if active_states.include?(state) && self.date <= Date.today + 7
  end

  def confirmable?
    confirmable_states = ['confirmed', 'new','booked', 'pending instructor', 'pending requester','']
    confirmable_states.include?(state)
  end

  def instructor_accepted?
    LessonAction.where(action:"Accept", lesson_id: self.id).any?
  end

  def declined_instructors
    decline_actions = LessonAction.where(action:"Decline", lesson_id: self.id)
    declined_instructors = []
    decline_actions.each do |action|
      declined_instructors << Instructor.find(action.instructor_id)
    end
    declined_instructors
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

  def calculate_actual_lesson_duration
    start_time = Time.parse(actual_start_time)
    end_time = Time.parse(actual_end_time)
    self.actual_duration = (end_time - start_time)/3600
  end

  def just_finalized?
    waiting_for_payment?
  end

  def price
    Product.where(location_id:self.requested_location.to_i,name:self.lesson_time.slot).first.price
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
    lesson_time_changes = self.lesson_time.attributes.diff(original_lesson.lesson_time.attributes)
    changed_attributes = lesson_changes.merge(lesson_time_changes)
    changed_attributes.reject { |attribute, change| ['updated_at', 'id', 'state', 'lesson_time_id'].include?(attribute) }
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
    if self.activity == 'Ski'
        wrong_sport = "Snowboard Instructor"
      else
        wrong_sport = "Ski Instructor"
    end
    active_resort_instructors = resort_instructors.where(status:'Active')
    wrong_sport_instructors = Instructor.where(sport: wrong_sport)
    already_booked_instructors = Lesson.booked_instructors(lesson_time)
    busy_instructors = Lesson.instructors_with_calendar_blocks(lesson_time)
    declined_instructors = []
    declined_actions = LessonAction.where(lesson_id: self.id, action:"Decline")
    declined_actions.each do |action|
      declined_instructors << Instructor.find(action.instructor_id)
    end
    # puts "The number of already booked instructors is: #{already_booked_instructors.count}"
    available_instructors = active_resort_instructors - already_booked_instructors - declined_instructors - wrong_sport_instructors - busy_instructors
    return available_instructors
    end
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
      recipient = self.available_instructors.first.phone_number
      @client = Twilio::REST::Client.new account_sid, auth_token
          @client.account.messages.create({
          :to => recipient,
          :from => "#{snow_schoolers_twilio_number}",
          :body => "#{self.available_instructors.first.first_name}, You have a new lesson request from #{self.requester.name} at #{self.start_time} on #{self.lesson_time.date} at #{self.location.name}. Are you available? Visit www.snowschoolers.com/lessons/#{self.id} to confirm the lesson."
      })
  end

  def send_sms_to_admin
      @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']
          @client.account.messages.create({
          :to => "408-315-2900",
          :from => ENV['TWILIO_NUMBER'],
          :body => "ALERT - no instructors are available to teach #{self.requester.name} at #{self.start_time} on #{self.lesson_time.date} at #{self.location.name}. The last person to decline was #{Instructor.find(LessonAction.last.instructor_id).username}."
      })
  end

  def send_sms_to_admin_1to1_request_failed
      @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']
          @client.account.messages.create({
          :to => "408-315-2900",
          :from => ENV['TWILIO_NUMBER'],
          :body => "ALERT - A private 1:1 request was made and declined. #{self.requester.name} had requested #{self.instructor.name} but they are unavailable at #{self.start_time} on #{self.lesson_time.date} at #{self.location.name}."
      })
  end

  private

  def instructors_must_be_available
    errors.add(:instructor, " not available at that time. Email info@snowschoolers.com to be notified if there are cancellations.") unless available_instructors.any?
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
    if self.active? #&& self.deposit_status == 'verfied'
      LessonMailer.send_lesson_request_to_instructors(self).deliver
      self.send_sms_to_instructor
    end
  end

  def no_instructors_post_instructor_drop?
    pending_requester?
  end
end
