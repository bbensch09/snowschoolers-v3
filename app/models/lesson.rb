require 'csv'

class Lesson < ActiveRecord::Base
  include ApplicationHelper
  belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'
  belongs_to :instructor
  belongs_to :lesson_time
  has_many :students
  has_one :review
  belongs_to :promo_code
  has_many :transactions
  has_many :lesson_actions
  belongs_to :product #, class_name: 'Product', foreign_key: 'product_id'
  belongs_to :section
  has_many :rentals
  has_one :report_card
  accepts_nested_attributes_for :students, reject_if: :all_blank, allow_destroy: true

  validates :requested_location, :lesson_time, :class_type, presence: true
  validates :phone_number,
            presence: true, on: :update
  # validates :duration, :start_time, presence: true, on: :update
  # validates :gear, inclusion: { in: [true, false] }, on: :update #gear now moved to student section
  # validates :terms_accepted, inclusion: { in: [true], message: 'must accept terms' }, on: :update
  validates :actual_start_time, :actual_end_time, presence: true, if: :just_finalized?
  # validate :requester_must_not_be_instructor, on: :create
  # validate :lesson_time_must_be_valid
  # validate :student_exists, on: :update

  #Check to ensure an instructor is available before booking
  validate :instructors_must_be_available, on: :create
  validate :group_students_are_old_enough, on: :update
  validate :time_slot_matches_group_or_private, on: :update
  validate :add_group_lesson_to_section, on: :create
  after_save :send_lesson_request_to_instructors
  before_save :calculate_actual_lesson_duration, if: :just_finalized?
  after_save :create_rental_reservation

  def self.replace_555_numbers
    lessons = Lesson.where(phone_number: '555-555-5555')
    lessons.each do |l|
      l.phone_number = '408-315-2900'
      l.save!
    end
  end

  def self.migrate_lesson_slots
    ActionMailer::Base.perform_deliveries = false
      Lesson.all.to_a.each do |lesson|
        if lesson.slot == 'Early Bird (8:45-9:45am)'
          lesson.lesson_time.update({slot:'1hr Early Bird 8:45-9:45am'})
        elsif lesson.slot == '1hr Private 10am' 
          lesson.lesson_time.update({slot:'1hr Private 10:00am'})
        elsif lesson.slot == '1hr Private 11:15am'
          lesson.lesson_time.update({slot:'1hr Private 11:15am'})        
        elsif lesson.slot == '1hr Private 12:30pm'
          lesson.lesson_time.update({slot:'1hr Private 12:30pm'})          
        elsif lesson.slot == 'Half-day Morning (10am-12:45pm)'
          lesson.lesson_time.update({slot:'Half-day Morning 10:00am-12:45pm'})          
        elsif lesson.slot == 'Half-day Afternoon (1:15-4pm)'
          lesson.lesson_time.update({slot:'Half-day Afternoon 1:15-4:00pm'})          
        elsif lesson.slot == 'Full-day (10am-4pm)'
          lesson.lesson_time.update({slot:'Full-day (10:00am-4:00pm)'})          
        elsif lesson.slot == '2hr Afternoon 1:45pm-3:45pm'
          lesson.lesson_time.update({slot:'2hr Group Afternoon 1:45pm-3:45pm'})
        else
          puts "!!! no updates made"
        end
      end
    ActionMailer::Base.perform_deliveries = false
  end

  def self.match_all_lessons_with_products
    ActionMailer::Base.perform_deliveries = false
      Lesson.all.to_a.each do |lesson|
        if lesson.product.nil?
          puts "!!!! found a lesson w/o matching product, so setting it to error product_id. Lesson ID was #{lesson.id}"
          lesson.product_id = Product.find(980191086).id
          lesson.save!
        end
      end
    ActionMailer::Base.perform_deliveries = false
  end

  def group_lesson?
    self.class_type == 'group'
  end

  def first_name
    requester_name.split(" ").first
  end

  def last_name
    requester_name.split(" ")[1..-1].join()
  end

  def private_lesson?
    self.class_type == 'private'
  end

  def class_type_text
    if self.class_type == 'group' && self.activity == 'Ski'
      return 'Group Ski Lesson'
    elsif self.class_type == 'group' && self.activity == 'Snowboard'
      return 'Group Snowboard Lesson'
    elsif self.class_type == 'private' && self.activity == 'Ski'
      return 'Private Ski Lesson'
    elsif self.class_type == 'private' && self.activity == 'Snowboard'
      return 'Private Snowboard Lesson'
      else 'N/A'
    end
  end

  def email_notifications_status
    email_status ? email_status : 'default (enabled)'
  end

  def sms_notification_status
    sms_status ? sms_status : 'default (enabled)'
  end

  def confirmation_number
    date = self.lesson_time.date.to_s.gsub("-","")
    date = date[4..-1]
    self.includes_rental_package? ? rental_code = "-R" : rental_code = ""

    case self.location.name
      when 'Granlibakken'
        l = 'GB'
      when 'Homewood'
        l = 'HW'
      else
        l = 'XX'
    end
    case self.class_type
      when nil
        class_type_code = 'SS'
      when 'group'
        class_type_code = 'GROUP'
      when 'private'
        class_type_code = 'PRIVATE'
      when ''
        class_type_code = 'UNKNOWN'
      when 'tickets'
        class_type_code = 'TICKETS'
      else 'NA'
    end
    id = self.id.to_s
    if self.class_type == 'tickets'
      confirmation_number = l+'-'+class_type_code+'-'+id+rental_code
    else
      confirmation_number = l+'-'+class_type_code.to_s+'-'+date+'-'+id+rental_code
    end
  end

  def contact_email
    if self.requester
      return self.requester.email
    elsif self.guest_email
      return self.guest_email
    end
  end
  def section_assignment_status
    if self.section_id.nil?
      return "Unassigned"
    else
      return "Assigned"
    end
  end

  def short_title
    if self.instructor && self.product
      title = "#{self.instructor.first_name} @ #{self.location.name}"
    elsif self.instructor.nil?
      title = "#{self.requester_name} @ #{self.location.name}"
    end
  end

  def self.seed_lessons(date,number)
    LessonTime.create!({
        date: date,
        slot: PRIVATE_SLOTS.sample
        })
    number.times do
      puts "!!! - first creating new student user"
      User.create!({
          email: Faker::Internet.email,
          password: 'homewood_temp_2017',
          user_type: "Student",
          name: Faker::Name.name
          })
      puts "!!! - user created; begin creating lesson"
      Lesson.create!({
          requester_id: User.last.id,
          deposit_status: "confirmed",
          # lesson_time_id: LessonTime.all.sample.id,
          lesson_time_id: LessonTime.last.id,
          activity: ["Ski","Snowboard"].sample,
          requested_location: "8",
          requester_name: User.last.name,
          phone_number: "530-430-7669",
          gear: [true,false].sample,
          lift_ticket_status: [true,false].sample,
          objectives: "I want to learn how to become the best skier on the mountain!",
          state: "booked",
          product_id: [1,4,10,14,14,14,14,15,15,15,15].sample,
          terms_accepted: true
        })
      puts "!!! - lesson created, creating students for lesson"
      last_lesson_product_age_type = Lesson.last.product.age_type
      if last_lesson_product_age_type == "Child"
        sample_age = (4..12).to_a.sample
      elsif last_lesson_product_age_type == "Adult"
        sample_age = (12..50).to_a.sample
      else
        sample_age = (4..50).to_a.sample
      end
      Student.create!({
          lesson_id: Lesson.last.id,
          name: "Student Jon",
          age_range: sample_age,
          gender: "Male",
          relationship_to_requester: "I am the student",
          most_recent_level: ["Level 1 - first-time ever, no previous experience.",
              "Level 2 - can safely stop on beginner green circle terrain.",
              "Level 3 - can makes wedge turns (heel-side turns for snowboarding) in both directions on beginner terrain.",
              "Level 4 - can link turns with moderate speed on all beginner terrain."].sample
        })
      puts "!!! - seed lesson created"
    end
  end

  def self.bookings_for_date(date)
    lessons = Lesson.all.to_a.keep_if{|lesson| lesson.date == date}
    return lessons.count
  end

  def date
    lesson_time.date
  end

  def self.set_all_lessons_to_Homewood
    Lesson.all.to_a.each do |lesson|
      if lesson.requested_location != 8
        lesson.requested_location = 8
        lesson.save
      end
    end
  end

  def slot
    lesson_time.slot
  end

  def length
    unless self.product.nil?
      return self.product.length
    end
  # remove old code below -- no longer using length as string
    # case self.lesson_time.slot
    #   when PRIVATE_SLOTS.first
    #     return "1.00"
    #   when PRIVATE_SLOTS.second
    #     return "1.00"
    #   when PRIVATE_SLOTS.third
    #     return "1.00"
    #   when PRIVATE_SLOTS.fourth
    #     return "1.00"
    #   when PRIVATE_SLOTS.fifth
    #     return "3.00"
    #   when PRIVATE_SLOTS[5]
    #     return "3.00"
    #   when PRIVATE_SLOTS[6]
    #     return "6.00"
    #   else
    #     return "2.00"
    #   end
  end

  def set_product_from_lesson_params
        puts "====begin method: set_product_from_lesson_params"
        if self.product_name
          # puts "!!!calculating price based on product length, location, and calendar_period"
          calendar_period = self.lookup_calendar_period(self.lesson_time.date,self.location.id)
          # puts "!!!!lookup calendar period status of lesson object, it is: #{calendar_period}"

          #pricing for Niseko
          if self.slot.include?('1hr') && self.location.name == "Niseko"
            product = Product.where(location_id:self.location.id,length:1.00,product_type:"private_lesson").first
          elsif self.slot.include?('Half-day Morning') && self.location.name == "Niseko"
            product = Product.where(location_id:self.location.id,length:3.00,product_type:"private_lesson").first
          elsif self.slot.include?('Half-day Morning') && self.location.name == "Niseko"
            product = Product.where(location_id:self.location.id,length:3.00,product_type:"private_lesson").last
          elsif self.slot.include?('Full-day') && self.location.name == "Niseko"
            product = Product.where(location_id:self.location.id,length:6.00,product_type:"private_lesson").first
          
          #pricing for Airbnb PRIVATES
          #2hr afternoons lesson with rental
          elsif self.slot == 'Airbnb Morning 10:00am-12:00pm' && self.location.id == 24 && self.class_type == "private"
            product = Product.where(location_id:self.location.id,length:2.00,calendar_period:calendar_period,slot:"Airbnb Morning 10:00am-12:00pm",product_type:"private_lesson").first
          #2hr afternoons lesson, with rental
          elsif self.slot == 'Airbnb Afternoon 1:30-3:30pm' && self.location.id == 24 && self.class_type == "private"
            product = Product.where(location_id:self.location.id,length:2.00,calendar_period:calendar_period,slot:"Airbnb Afternoon 1:30-3:30pm",product_type:"private_lesson").first

          #pricing for Airbnb GROUPS
          #2hr afternoons lesson, with rental
          elsif self.slot == 'Airbnb Morning 10:00am-12:00pm' && self.location.id == 24 && self.class_type == "group"
            product = Product.where(location_id:self.location.id,length:2.00,slot:"Airbnb Morning 10:00am-12:00pm",product_type:"group_lesson").first
          #2hr afternoons lesson, with rental
          elsif self.slot == 'Airbnb Afternoon 1:30-3:30pm' && self.location.id == 24 && self.class_type == "group"
            product = Product.where(location_id:self.location.id,length:2.00,slot:"Airbnb Afternoon 1:30-3:30pm",product_type:"group_lesson").first


          #pricing for Granlibakken GROUPS
          #2hr afternoons lesson, no rental
          elsif self.slot == '2hr Group Afternoon 1:45pm-3:45pm' && self.location.id == 24 && self.class_type == 'group' && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:2.00,calendar_period:calendar_period,product_type:"group_lesson",is_lift_rental_package:false).first
          #2hr afternoons lesson, with rental
          elsif self.slot == '2hr Group Afternoon 1:45pm-3:45pm' && self.location.id == 24 && self.class_type == 'group' && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:2.00,calendar_period:calendar_period,product_type:"group_lesson",is_lift_rental_package:true).first


          #pricing for Granlibakken PRIVATES
          #early bird w/o rental
          elsif self.slot == '1hr Early Bird 8:45-9:45am' && self.location.id == 24 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.00,slot:'1hr Early Bird 8:45-9:45am',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:true).first
          #early bird w/ rental
          elsif self.slot == '1hr Early Bird 8:45-9:45am' && self.location.id == 24 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.00,slot:'1hr Early Bird 8:45-9:45am',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first

          #1hr morning private w/o rental @10am start
          elsif self.slot == '1hr Private 10:00am' && self.location.id == 24 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.00,slot:'1hr Private 10:00am',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:true).first
          #1hr morning private WITH rental @10am start
          elsif self.slot == '1hr Private 10:00am' && self.location.id == 24 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.00,slot:'1hr Private 10:00am',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first

          #1hr morning private w/o rental @1115am start
          elsif self.slot == '1hr Private 11:15am' && self.location.id == 24 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.00,slot:'1hr Private 11:15am',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:true).first
          #1hr morning private WITH rental @1115am start
          elsif self.slot == '1hr Private 11:15am' && self.location.id == 24 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.00,slot:'1hr Private 11:15am',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first

          #1hr morning private w/o rental @1230pm start
          elsif self.slot == '1hr Private 12:30pm' && self.location.id == 24 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.00,slot:'1hr Private 12:30pm',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:true).first
          #1hr morning private WITH rental @1230pm start
          elsif self.slot == '1hr Private 12:30pm' && self.location.id == 24 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.00,slot:'1hr Private 12:30pm',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first

          #1hr morning private w/o rental @145 start
          elsif self.slot == '1hr Private 1:45pm' && self.location.id == 24 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.00,slot:'1hr Private 1:45pm',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:true).first
          #1hr morning private WITH rental @145 start
          elsif self.slot == '1hr Private 1:45pm' && self.location.id == 24 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.00,slot:'1hr Private 1:45pm',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first

          #1hr morning private w/o rental @3pm start
          elsif self.slot == '1hr Private 3:00pm' && self.location.id == 24 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.00,slot:'1hr Private 3:00pm',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:true).first
          #1hr morning private WITH rental @3pm start
          elsif self.slot == '1hr Private 3:00pm' && self.location.id == 24 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.00,slot:'1hr Private 3:00pm',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first

          #pricing for morning GB half-day morning package
          elsif self.slot == 'Half-day Morning 10:00am-12:45pm' && self.location.id == 24 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:3.00,slot:'Half-day Morning 10:00am-12:45pm',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:true).first
          #pricing for morning GB half-day morning lesson only
          elsif self.slot == 'Half-day Morning 10:00am-12:45pm' && self.location.id == 24 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:3.00,slot:'Half-day Morning 10:00am-12:45pm',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first

          #pricing for afternoon GB half-day package
          elsif self.slot == 'Half-day Afternoon 1:15-4:00pm' && self.location.id == 24 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:3.00,slot:'Half-day Afternoon 1:15-4:00pm',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:true).first
          #pricing for afternoon GB half-day lesson only
          elsif self.slot == 'Half-day Afternoon 1:15-4:00pm' && self.location.id == 24 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:3.00,slot:'Half-day Afternoon 1:15-4:00pm',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first

          #pricing for GB full-day lesson package
          elsif self.slot == 'Full-day (10:00am-4:00pm)'  && self.location.id == 24 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:6.00,slot:'Full-day (10:00am-4:00pm)',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:true).first
          #pricing for GB full-day lesson only
          elsif self.slot == 'Full-day (10:00am-4:00pm)'  && self.location.id == 24 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:6.00,slot:'Full-day (10:00am-4:00pm)',calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first


          #pricing for Homewood
          #early bird w/o rental
          elsif self.slot == '1hr Early Bird 8:45-9:45am' && self.location.id == 8 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.0,calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first
          #early bird w/ rental
          elsif self.slot == '1hr Early Bird 8:45-9:45am' && self.location.id == 8 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:1.0,calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first


          # MUST FIX ALL HOMEWOOD PRODUCTS & PRICING WHEN REACTIVATED
          # default HW lessons to show 9,999 to ensure no one accidently books.
          elsif self.location.id ==8
            product = Product.find(980191086)
            @check_999_products = true
          #pricing for morning homewood half-day package
          elsif self.slot.include?("Half-day Morning") && self.location.id == 8 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:3.0,calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first
          #pricing for morning homewood half-day lesson only
          elsif self.slot.include?("Half-day Morning") && self.location.id == 8 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:3.0,calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first

          #pricing for afternoon homewood half-day package
          elsif self.slot.include?("Half-day Afternoon") && self.location.id == 8 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:3.0,calendar_period:calendar_period,slot:"Half-day Afternoon 1:15-4:00pm",product_type:"private_lesson",is_lift_rental_package:false).first
          #pricing for afternoon homewood half-day lesson only
          elsif self.slot.include?("Half-day Afternoon") && self.location.id == 8 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:3.0,calendar_period:calendar_period,slot:"Half-day Afternoon 1:15-4:00pm",product_type:"private_lesson",is_lift_rental_package:false).first

          #pricing for homewood full-day lesson package
          elsif self.slot.include?("Full-day") && self.location.id == 8 && self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:6.0,calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first
          #pricing for homewood full-day lesson only
          elsif self.slot.include?("Full-day") && self.location.id == 8 && !self.includes_rental_package?
            product = Product.where(location_id:self.location.id,length:6.0,calendar_period:calendar_period,product_type:"private_lesson",is_lift_rental_package:false).first
        end
        unless product.nil?
          puts "===lesson id is #{self.id}. preparing to save new product_id"
          self.update({product_id:product.id})
        end
        if product.nil? && state == 'new'
          product = Product.find(980191086)
          @check_999_products = true
          # hard-code product id for default fallback option
          puts "!!!! since no matching product was found, setting id to hard coded value of 980191086, which will show error to user and prevent other errors"
        self.update({product_id:980191086})
        end
      end
      return product
  end

  def product
      puts "!!!!!! begining Lesson.product"
        # HACKY CODE TO REMOVE --  added in effort to reduce latency by storing/retrievingproduct_id
        # puts "!!! the param to skip product_id is #{@skip_product_id}"
        # if @skip_product_id == 'blue'
        #   return Product.find(self.product_id)
        # end
      if product_id.nil? || (product_id == 980191086 && @check_999_products != true)
      # triggerd stack level too deep error (?)
      # if product_id.nil? or Product.where(id:product_id).count == 0 or product_id == 980191086
        set_product_from_lesson_params
      elsif product_id
        if Product.where(id:product_id).count == 0
          puts "!!! product_id exists, but the there is now product found in database with that ID (e.g. 54)"
          set_product_from_lesson_params
        else
          puts "!!! lesson has stored product_id - skip rest of method to assign product"
          return Product.find(product_id)
        end
      end
  end

  def tip
    if self.transactions.any?
    tip_amount = (self.transactions.last.final_amount - self.transactions.last.base_amount)
    tip_amount = ((tip_amount*100).to_i).to_f/100
    else
      return "N/A"
    end
  end

  def final_charge
    self.transactions.last.final_amount - self.lesson_price.to_i
  end

  def post_stripe_tip
    if tip <= 0
      return 0
    else
      return (self.tip * 0.971) - 0.30
    end
  end

  def airbnb?
    if !self.additional_info.nil? && self.additional_info.include?("T")
      puts "!!!! lesson classified as Airbnb and has confirmation code indicating has been paid."
      return true
    elsif
      self.package_info && self.package_info.downcase.include?('airbnb')
      return true
    else 
      return false
    end
  end

  def partially_booked?
    if self.deposit_status && self.deposit_status == "partially booked"
      return true
    else 
      return false
    end
  end

  def private_request?
    if self.bonus_category == 'private request'
      return 'Yes'
    else
      return 'No'
    end
  end

  def bad_weather?
    unless self.bonus_category == 'weather'
      return false
    end
  end

  def kids_under_6?
    bonus_boolean = false
    self.students.each do |student|
      if student.age_range.to_i <= 6
        bonus_boolean = true
      end
    end
    return bonus_boolean
  end

  def bonus_rate
    if self.private_request? == 'Yes'
      return 10
    elsif self.bad_weather?
      return 10
    elsif self.kids_under_6?
      return 5
    else
      return 0
    end
  end

  def bonus_wages
    if self.hourly_bonus
      rate = self.hourly_bonus
      else
      rate = self.bonus_rate
    end
    if self.product
      amount = self.product.length.to_i * rate
    else
      amount = 0
    end
    return amount
  end

  def wages
    instructor = self.instructor

    if instructor && self.product
      wages = self.product.length.to_i * instructor.wage_rate
    elsif self.product
      wages = self.product.length.to_i * 16
    else
      wages = 0
    end
    return wages
  end

  def self.total_prime_days
    total = 0
    Instructor.active_instructors.each do |instructor|
      total += instructor.prime_days_available
      total += instructor.prime_days_booked
    end
    return total
  end

  def self.to_csv(options = {})
    desired_columns = %w{ id start_time lesson_time_id activity product_name instructor_id state public_feedback_for_student how_did_you_hear
    }
    CSV.generate(headers: true) do |csv|
      csv << desired_columns
      all.each do |lesson|
        csv << lesson.attributes.values_at(*desired_columns)
      end
    end
  end

  def self.to_csv2(options = {})
    CSV.open(lessons,'w') do |csv|
      csv << %w{ id start_time lesson_time_id activity product_name instructor_id state public_feedback_for_student how_did_you_hear}
      Lesson.where(instructor_id:1).each do |l|
        csv << l.attributes.values
      end
    end
  end

  def this_season?
    self.lesson_time.date.to_s >= '2019-12-01'
  end

  def last_season?
    self.lesson_time.date.to_s <= '2019-04-30' && self.lesson_time.date.to_s >= '2018-12-01'
  end

  def first_season?
    self.lesson_time.date.to_s <= '2018-04-30'
  end

  def self.completed_lessons
    lessons = Lesson.all.select{|lesson| lesson.this_season? && lesson.completed? }
  end

  def self.completed_last_year
    lessons = Lesson.all.select{|lesson| lesson.last_season? && lesson.completed? }
  end

  def self.excluded_lessons
    Lesson.where(focus_area:'Exclude')
  end

  def excluded_lesson?
    return true if self.focus_area == 'Exclude'
  end

  def self.open_lesson_requests
    lessons = Lesson.where(state:'booked',instructor_id:nil)
    lessons.select{|lesson| lesson.this_season?}
  end

  def self.group_sections_available(date,lesson_time)
    lessons = Lesson.where(state:'booked',class_type:'group').select{|l| l.date == date}
    if lesson_time.slot == 'Half-day Morning (10am-12:45pm)' || lesson_time.slot == '2hr Morning 10am-12pm'
        am_lessons = lessons.select{|lesson| lesson.start_time == '2hr Morning 10am-12pm'}
      elsif lesson_time.slot == 'Half-day Afternoon (1:15-4pm)' || lesson_time.slot == '2hr Afternoon 1pm-3pm' 
        pm_lessons = lessons.select{|lesson| lesson.start_time == '2hr Afternoon 1pm-3pm'}
      else
        lesson = lessons
    end   

    # determine number of morning group sections with at least one booking
    unless am_lessons.nil?
      am_section_ids = []
      am_lessons.each do |l|
        am_section_ids << l.section.id
      end
      puts "!!!! am section_ids are: #{am_section_ids}"
      am_sections_count = am_section_ids.uniq.count
    end

    # determine number of afternoon group sections with at least one booking
    unless pm_lessons.nil?
      pm_section_ids = []
      pm_lessons.each do |l|
        pm_section_ids << l.section.id
      end
      puts "!!!! pm section_ids are: #{pm_section_ids}"
      pm_sections_count = pm_section_ids.uniq.count
    end

    if lesson_time.slot == 'Half-day Morning (10am-12:45pm)' || lesson_time.slot == '2hr Morning 10am-12pm'
        return am_sections_count
      elsif lesson_time.slot == 'Half-day Afternoon (1:15-4pm)' || lesson_time.slot == '2hr Afternoon 1pm-3pm' 
        return pm_sections_count
      elsif lesson_time.slot == 'Full Day'
        return [am_sections_count,pm_sections_count].max
      else
        return 0
      end
  end

  def self.canceled_lessons
    lessons = Lesson.where(state:'canceled')
    lessons.select{|lesson| lesson.this_season?}
  end


  def self.confirmed_lessons
    lessons = Lesson.select{|lesson| !lesson.instructor_id.nil? && lesson.this_season? && !lesson.canceled?}
  end

  def self.open_lesson_requests_on_day(date)
    lessons = Lesson.where(state:'booked',instructor_id:nil)
    lesson = lessons.select{|lesson| lesson.date == date}
  end

  def self.open_booked_revenue
    lessons = Lesson.open_lesson_requests
    total = 0
    lessons.each do |lesson|
      unless lesson.focus_area == "Exclude"
        total += lesson.price.to_i
      end
    end
    return total
  end

  def self.closed_booked_revenue
    lessons = Lesson.confirmed_lessons
    total = 0
    lessons.each do |lesson|
      unless lesson.focus_area == "Exclude"
        total += lesson.price.to_i
      end
    end
    return total
  end

  def self.other_revenue
    lessons = Lesson.all
    total = 0
    lessons.each do |lesson|
      if lesson.focus_area == "Exclude"
        total += lesson.price.to_i
      end
    end
    return total
  end

  def self.open_wages_available
    lessons = Lesson.open_lesson_requests
    total = 0
    lessons.each do |lesson|
      total += (lesson.length.to_i * 16)
    end
    return total
  end


  def self.total_wages
    total = 0
    Instructor.active_instructors.each do |instructor|
      total += instructor.total_wages
    end
    return total
  end

  def self.paid_wages_to_date
    total = 0
    Instructor.active_instructors.each do |instructor|
      total += instructor.paid_wages_to_date
    end
    return total
  end

  def self.total_tips
    total = 0
    Instructor.active_instructors.each do |instructor|
      total += instructor.total_tips
    end
    return total
  end

  def self.total_earnings
    total = 0
    Instructor.active_instructors.each do |instructor|
      total += instructor.total_earnings
    end
    return total
  end

  def lift_ticket_status?
    return true if self.lift_ticket_status == "Yes, I have one."
  end

  def location
    if self.requested_location.to_i == 0
      Location.find(24)
    elsif self.requested_location.nil?
      Location.find(24)
    else
      Location.find(self.requested_location.to_i)
    end
  end

  def active?
    active_states = ['new', 'booked', 'confirmed','ready_to_book','pending instructor','gift_voucher_reserved','pending requester','']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    active_states.include?(state)
  end

  def active_today?
    active_states = ['confirmed','seeking replacement instructor','pending instructor','booked','pending requester','Lesson Complete','finalizing payment & reviews','waiting for review','finalizing','ready_to_book']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    return true if self.date == Date.today && active_states.include?(state)
  end

  def upcoming?
    active_states = ['new','booked','confirmed','seeking replacement instructor','pending instructor', 'pending requester','Lesson Complete','finalizing payment & reviews','waiting for review','finalizing','ready_to_book']
    return true if active_states.include?(state) && self.date > Date.today
  end

  def waiver?
    active_states = ['new','booked','confirmed','seeking replacement instructor','pending instructor', 'pending requester','ready_to_book']
    return true if active_states.include?(state)
  end

  def confirmable?
    return false if self.group_lesson?
    confirmable_states = ['booked', 'pending instructor', 'pending requester','seeking replacement instructor']
    confirmable_states.include?(state) #&& self.available_instructors.any?
  end

  def is_gift_voucher?
    if self.is_gift_voucher == true
      return true
    else
      return false
    end
  end

  def includes_rental_package?
    count_students_with_rentals = 0
    self.students.each do |student|
      if student.needs_rental == true
        count_students_with_rentals += 1
      end
    end
    if count_students_with_rentals > 0
     true
   else
     false
   end
  end

  def rental_status
    if !self.includes_rental_package?
      return 'N/A'
    else
      rentals = self.rentals
      status = 'Equipment Reserved'
      rentals.each do |rental|
        status = "Pending" if rental.status != 'Reserved'
      end
      return status
    end
  end

  def start_time
    if self.planned_start_time && self.planned_start_time.length > 1
      return self.planned_start_time
    elsif self.lesson_time_id
      return self.slot
    elsif self.product_id
      return Product.find(self.product_id).start_time
    elsif self.product
      return self.product.start_time
    else
      return "Unknown"
    end
  end

  def includes_admin_lift_or_rental_package?
    if self.includes_lift_or_rental_package == true
      return true
    else
      return false
    end
  end

  def confirmed?
    confirmed_states = ['confirmed', 'pending instructor', 'pending requester']
    confirmed_states.include?(state)
  end

  def completable?
    return false if self.group_lesson?
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
    state == 'waiting for review'
  end

  def custom_start_time?
    if self.package_info && self.package_info.include?("custom start time")
      return true
    else
      false
    end
  end

  def completed?
    active_states = ['finalizing','finalizing payment & reviews','Payment complete, waiting for review.','waiting for payment','Lesson Complete']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    active_states.include?(state)
  end

  def payment_complete?
    state == 'Payment complete, waiting for review.' || state == 'Lesson Complete'
  end

  def ready_for_deposit?
     self.state == "ready_to_book" || self.deposit_status.nil? || self.deposit_status == 'pending_new_payment'
  end

  def booked?
    self.deposit_status == 'confirmed' || self.deposit_status == 'pending_new_payment' || self.airbnb?
  end

  def eligible_for_payroll?
    eligible_states = ['finalizing','finalizing payment & reviews','Payment complete','waiting for review','waiting for payment','Lesson Complete','confirmed','booked','pending instructor','seeking replacement instructor']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    eligible_states.include?(state) && self.this_season?
  end

  def has_review?
    return true if self.review && self.review.rating != nil
  end

  def has_review_and_feedback?
    return true if self.review && self.review.review != nil
  end

  def non_lesson_revenue
    lift_only_revenue = self.students_without_gear * 15
    rental_packages_revenue = self.students_with_gear * 30
    non_lesson_revenue = lift_only_revenue + rental_packages_revenue
  end

  def lesson_revenue
    if self.price.to_i
      return self.price - self.non_lesson_revenue
    end
  end

  def gross_margin
    self.lesson_revenue - self.wages
  end

#CLASS METHODS FOR TABLE TOTALS

  def self.gross_revenue_total(lessons)
    total = 0
    lessons.each do |lesson|
      if lesson.price.is_a? Numeric
      total += lesson.price
      end
    end
    return total
  end

  def self.non_lesson_revenue_total(lessons)
    total = 0
    lessons.each do |lesson|
      total += lesson.non_lesson_revenue
    end
    return total
  end

  def self.lesson_revenue_total(lessons)
    total = 0
    lessons.each do |lesson|
      total += lesson.lesson_revenue
    end
    return total
  end

  def self.payroll_total(lessons)
    total = 0
    lessons.each do |lesson|
      total += lesson.wages
    end
    return total
  end

  def self.gross_margin_total(lessons)
    total = 0
    lessons.each do |lesson|
      total += lesson.gross_margin
    end
    return total
  end

  def referral_source
    case self.how_did_you_hear.to_i
    when 1
      return 'From a friend'
    when 2
      return 'Facebook'
    when 3
      return 'Google'
    when 4
      return 'From a postcard'
    when 5
      return 'From someone at Homewood'
    when 6
      return 'Tahoe Daves'
    when 7
      return 'Ski Butlers'
    when 8
      return 'Yelp'
    when 100
      return 'Other'
    end
  end

  def instructor_accepted?
    LessonAction.where(action:"Accept", lesson_id: self.id).any?
  end

  def instructor_assigned?
    return true unless instructor_id.nil?
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

  def lookup_calendar_period(date,location_id)
    date = date.to_s
    case location_id
      when 8
        if HW_HOLIDAYS.include?(date)
          return 'Holiday'
        elsif HW_PEAK.include?(date)
          return 'Peak'
        else
          return 'Regular'
        end
      when 24
        if GB_HOLIDAYS.include?(date)
          return 'Holiday'
        else
          return 'Regular'
        end
    end
  end

  def price
    puts "!!!! running Lesson.price method to determine current price."
    # begin work to reduce price/product calls which are causing application errors
    # return self.lesson_price if self.lesson_price != nil
    product = self.product
    if product.nil?
      return 0
      # returning integer rather than string formula to ensure price can always be summed
      # return "Please confirm date & time to see price."
    else
    price = product.price.to_f + self.package_cost
    end
    if self.class_type == 'group'
      price = product.price * [1,self.students.count].max
    end

    if self.promo_code
      case self.promo_code.discount_type
      when 'cash'
        # puts "!!!discount of #{self.promo_code.discount} is applied to total price."
        price = (price.to_f - self.promo_code.discount.to_f)
      when 'percent'
        # puts "!!!discount percentage of of #{self.promo_code.discount} is applied to total price."
        price = (price.to_f * (1-self.promo_code.discount.to_f/100))
      end
    end
    return price.to_f
  end

  def original_price
    return self.price unless self.promo_code
    case self.promo_code.discount_type
      when 'cash'
        return original_price = self.price.to_f + self.promo_code.discount.to_f
      when 'percent'
        return original_price = self.price.to_f / (1-self.promo_code.discount.to_f/100)
      end
  end

  def adjusted_price
    return self.price if self.actual_duration.nil? && self.admin_price_adjustment.nil?
    if self.actual_duration
        delta = actual_duration - self.product.length.to_i
        if delta == 3 && self.product.length.to_i == 1
          upsell_type = "extend_early_bird_to_half"
        elsif delta == 6 && self.product.length.to_i == 1
          upsell_type = "extend_early_bird_to_full"
        elsif delta == 3 && self.product.length.to_i == 3
          upsell_type = "extend_half_day_to_full"
        else
          puts "!!!!could not compute an extension type"
        end
        calendar_period = self.lookup_calendar_period(self.lesson_time.date,self.location.id)
        case upsell_type
          when "extend_early_bird_to_half"
            product = Product.where(length:3.00,location_id:self.location.id,calendar_period:calendar_period,product_type:"private_lesson").first
          when "extend_half_day_to_full"
            product = Product.where(length:6.00,location_id:self.location.id,calendar_period:calendar_period,product_type:"private_lesson").first
          when "extend_early_bird_to_full"
            product = Product.where(length:6.00,location_id:self.location.id,calendar_period:calendar_period,product_type:"private_lesson").first
          else
            product = self.product
        end
      puts "!!!!!! length of lesson extension = #{delta}"
      puts "!!!!!! the final product is #{product.name} and has a price of #{product.price}"
      if self.lesson_price && self.lesson_price > product.price
        base_price = self.lesson_price
      else
        base_price = product.price
      end
    elsif self.lesson_price
      base_price = self.lesson_price
    else
      base_price = self.product.price
    end
    admin_adjustment = self.admin_price_adjustment.to_f
    puts "!!!!!! there is also an admin adjustment of #{admin_adjustment}"
    adjusted_price = base_price.to_f + admin_adjustment.to_f
  end


  def package_cost
    return 0 if self.students.count == 0 || class_type == 'group'
    package_price = 0
    puts "!!!calculating package cost"
    p1 = self.additional_students_with_gear.to_i * self.cost_per_additional_student_with_gear
    p2 = self.additional_students_without_gear.to_i * self.cost_per_additional_student_without_gear
    package_price = p1 + p2
  end

  def cost_per_additional_student_with_gear
    case self.location.id
      when 24
        return 60
      when 8
        return 0
      else
        return 0
    end
  end

  def cost_per_additional_student_without_gear
    case self.location.id
      when 24
        return 40
      when 8
        return 0
      else
        return 0
    end
  end

  def students_with_gear
      count = 0
      self.students.each do |student|
        if student.needs_rental
          count += 1
        end
      end
      return count
  end

  def students_without_gear
      count = 0
      self.students.each do |student|
        unless student.needs_rental
          count += 1
        end
      end
      return count
  end

  def additional_students_with_gear
    if self.location.id == 24
      if self.students_with_gear > 0
        return self.students_with_gear - 1
      else
        return 0
      end
    else
      return self.students_with_gear.to_i
    end
  end

  def additional_students_without_gear
    if self.location.id == 24
      if self.students_with_gear > 0
        return self.students_without_gear.to_i
      elsif self.students_with_gear == 0
        return (self.students_without_gear - 1).to_i
      else
        return 0
      end
    else
      return self.students_without_gear.to_i
    end
  end

  def visible_lesson_cost
    if self.lesson_cost.nil?
      return self.price
    else
      return self.lesson_cost
    end
  end

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

  def levels_range
    return false if self.students.nil?
    student_levels = []
    self.students.each do |student|
      #REFACTOR ALERT extract the 7th character from student experience level, which yields the level#, such as in 'Level 2 - wedge turns...'
      student_levels << student.most_recent_level[6].to_i
    end
    return [student_levels.min..(student_levels.max+1)]
  end

  def athlete
    if self.activity == "Ski"
      return "skier"
    else
      return "snowboarder"
    end
  end

  def sport_id
    if self.activity == "Ski"
      Sport.where(name:"Ski Instructor").first.id
    else
      Sport.where(name:"Snowboard Instructor").first.id
    end
  end

  def group_students_are_old_enough
    return true if self.private_lesson?  || self.state == 'booked' || self.state == 'confirmed'
    self.students.each do |student|
      if student.age_range.to_i < 8
        puts "!!!!students are NOT old enough"
        errors.add(:lesson, "Group lessons are only for students 8 and up. Please select a private lesson for children 7 and under.")
        return false
      else
        puts "!!!!students are all old enough for groups"
      end
    end
  end

  def time_slot_matches_group_or_private
    if self.group_lesson?
      if !VALID_GROUP_SLOTS.include?(self.slot)
        errors.add(:lesson, "You've selected a group lesson with at private lesson time. Group lessons are only offered at 1:45pm, so please select that time slot to continue.")
        return false
      end
    elsif self.private_lesson?
      if VALID_GROUP_SLOTS.include?(self.slot)
        errors.add(:lesson, "You've selected a private lesson at the group time slot. Please select a valid private lesson time to continue.")
        return false
      end
    else
      return true
    end
  end

  def available_sections
    sections = Section.where(sport_id:self.sport_id,date:self.lesson_time.date)
    sections = sections.select{|section| section.has_capacity?}
  end

  def ticket_price
    return 0 if self.class_type != 'tickets'
    case activity
    when 'Child'
      return CHILD_HW_TICKET_PRICE
    when 'Teen'
      return TEEN_HW_TICKET_PRICE
    when 'Adult'
      return ADULT_HW_TICKET_PRICE
    else
      return 60
    end
  end

  def total_ticket_price
    self.ticket_price * self.num_days
  end

  def add_group_lesson_to_section
    puts "!!!! skip adding to section if private lesson !!!!!"
    return true if self.private_lesson?
    return true if self.class_type == "tickets"
    return true if self.section_id && self.sport_id == self.section.sport_id && self.date == self.section.date
    existing_sections = self.available_sections
      if self.available_sections.count == 0
      puts "!!!!!!!! The requested time slot is full!!!!!"
      self.state = 'This section is unfortunately full, please choose another time slot.'
      errors.add(:lesson, "There is unfortunately no more open spots in this group lesson, please try another time slot or contact us by email at hello@snowschoolers.com or by phone at 530-430-SNOW.")
      notify_admin_group_lessons_sold_out(self.lesson_time,self.activity,self.guest_email)
      return false
      end
      puts "!!!!section available is #{available_sections.first }"
      self.section_id = available_sections.first.id
      self.state = "new"
  end

  def confirm_section_valid
    if self.section.nil?
      if self.available_sections.count == 0
          errors.add(:lesson, "There is unfortunately no more open spots in this group lesson, please try another time slot or contact us by email at hello@snowschoolers.com or by phone at 530-430-SNOW.")
          return false
      end
      self.section_id = self.available_sections.first.id
      self.save
    elsif self.section.remaining_capacity <= 0
      puts "!!!!warning, at capcity"
    else self.section.remaining_capacity >= 1
      return true
    end
  end

  def confirm_valid_email
    if self.guest_email
      puts "!!! user guest emails is: #{self.guest_email.downcase}"
      if self.requester_id
        return true
      elsif User.find_by_email(self.guest_email.downcase)
          self.requester_id = User.find_by_email(self.guest_email.downcase).id
          puts "!!!! user is checking out as guest; found matching email from previous entry"
          return true
      elsif self.guest_email.include?("@")
          User.create!({
          email: self.guest_email,
          password: 'sstemp2017',
          user_type: "Student",
          name: "#{self.guest_email}"
          })
         self.requester_id = User.last.id
         return true
         puts "!!!! user is checking out as guest; create a temp email for them that must be confirmed"
       else
        errors.add(:lesson, "Please enter a valid email, or sign-into your account.")
        return false
      end
    end
  end

  def self.assign_all_instructors_to_sections
    unassigned_sections = Section.all.select{|section| section.instructor_id.nil?}
    unassigned_sections.each do |section|
      section.instructor_id = section.available_instructors.first.id
      section.save!
    end
    unassigned_lessons = Lesson.where(instructor_id:nil)
    puts "!!!!!!!!! there are #{unassigned_lessons.count} unassigned lessons"
    unassigned_lessons.each do |lesson|
      if lesson.section.nil?
        lesson.section_id = lesson.available_sections.first ? lesson.available_sections.first.id : Section.first.id
        lesson.instructor_id = lesson.section.instructor_id
        lesson.save
      end
    end
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
    puts "!!!!!!! - Step #1 Filtered for location, found #{resort_instructors.count} instructors."
    active_resort_instructors = resort_instructors.where(status:'Active')
    puts "!!!!!!! - Step #2 Filtered for active status, found #{active_resort_instructors.count} instructors."
    if self.activity == 'Ski' && self.level
      active_resort_instructors = active_resort_instructors.to_a.keep_if {|instructor| (instructor.ski_levels.any? && instructor.ski_levels.max.value >= self.level) }
    end
    if self.activity == 'Snowboard' && self.level
      active_resort_instructors = active_resort_instructors.to_a.keep_if {|instructor| (instructor.snowboard_levels.any? && instructor.snowboard_levels.max.value >= self.level )}
    end
    puts "!!!!!!! - Step #3 Filtered for level, found #{active_resort_instructors.count} instructors."
    if kids_lesson?
      active_resort_instructors = active_resort_instructors.to_a.keep_if {|instructor| instructor.kids_eligibility == true }
      puts "!!!!!!! - Step #3b Filtered for kids specialist, now have #{active_resort_instructors.count} instructors."
    end
    if seniors_lesson?
      active_resort_instructors = active_resort_instructors.to_a.keep_if {|instructor| instructor.seniors_eligibility == true }
      puts "!!!!!!! - Step #3c Filtered for seniors specialist, now have #{active_resort_instructors.count} instructors."
    end
    if self.activity == 'Ski'
        active_resort_instructors = active_resort_instructors.to_a.keep_if {|instructor| instructor.ski_instructor? }
      elsif self.activity == "Snowboard"
        active_resort_instructors = active_resort_instructors.to_a.keep_if {|instructor| instructor.snowboard_instructor? }
      elsif self.activity == "Telemark"
        active_resort_instructors = active_resort_instructors.to_a.keep_if {|instructor| instructor.telemark_instructor? }
    end
    puts "!!!!!!! - Step 3d Filtere for correct sport, found #{active_resort_instructors.count} instructors."
    already_booked_instructors = Lesson.booked_instructors(lesson_time)
    busy_instructors = Lesson.instructors_with_calendar_blocks(lesson_time)
    declined_instructors = []
    #ignore decline actions for future availability >> instructors may decline based on the lesson info, not they're actual availability
    # declined_actions = LessonAction.where(lesson_id: self.id, action:"Decline")
    # declined_actions.each do |action|
      # declined_instructors << Instructor.find(action.instructor_id)
    # end
    puts "!!!!!!! - Step #4b - eliminating #{already_booked_instructors.count} that are already booked."
    already_booked_names = []
    already_booked_instructors.each do |instructor|
      already_booked_names << instructor.name
      puts "!!! #{instructor.name} is already booked."
    end
    puts "!!!!!!! - Step #4c - no longer eliminating instructors that have declined."
    puts "!!!!!!! - Step #4d - eliminating #{busy_instructors.count} that are busy."
    busy_names = []
    busy_instructors.each do |instructor|
      busy_names << instructor.name
      puts "!!! #{instructor.name} is unavailable on #{self.lesson_time.date}."
    end
    available_instructors = active_resort_instructors - already_booked_instructors - declined_instructors - busy_instructors
    puts "!!!!!!! - Step #5 after all filters, found #{available_instructors.count} instructors."
    available_instructors = self.rank_instructors(available_instructors)
    return available_instructors
    end
  end

  def rank_instructors(available_instructors)
    puts "!!!!!!!ranking instructors now"
    available_instructors.sort! {|a,b| b.overall_score <=> a.overall_score }
    return available_instructors
  end

def available_instructors?
    puts "!!!!!! checking to see if there are any available instructors"
    # available_instructors.any? ? true : false
    if available_instructors.count == 0
      puts "!!!found zero instructors"
      return false
    # elsif self.requester && (self.requester.user_type == "Snow Schoolers Employee" || self.requester.email == "brian@snowschoolers.com")
    #   return true
    else
      all_open_lesson_requests = Lesson.open_lesson_requests
      overlapping_open_private_lesson_requests = all_open_lesson_requests.select{|lesson| lesson.date == self.date && lesson.lesson_time.slot == self.lesson_time.slot}
      overlapping_group_sections = Lesson.group_sections_available(self.date,self.lesson_time)          
      actual_availability_count = available_instructors.count - overlapping_open_private_lesson_requests.count - overlapping_group_sections
      puts "!!!actual available count is currently: #{actual_availability_count}"
      case actual_availability_count.to_i
      when 2..100
        puts "!!! Estimated actual availability at this time slot is #{actual_availability_count}"
        return true
      when 0..1
        puts "!!! Warning: at most 1-2 instructors are available"
        return true
      when 0
        puts "!!! Error: no instructors are available."
        return false
      when -10...-1
        puts "!!! Error: we are OVERBOOKED no instructors are available."
        return false
      else
        return false
      end
    end
  end

  def self.find_lesson_times_by_requester(user)
    self.where('requester_id = ?', user.id).map { |lesson| lesson.lesson_time }
  end

  def self.instructors_with_calendar_blocks(lesson_time)
    calendar_blocks = CalendarBlock.where(date:lesson_time.date, state:'Not Available')
    blocked_instructors =[]
    calendar_blocks.each do |block|
      if block.instructor_id && block.instructor_id > 0
        blocked_instructors << Instructor.find(block.instructor_id)
      end
    end
    return blocked_instructors
  end

  def self.find_calendar_blocks(lesson_time)
    same_slot_blocks = CalendarBlock.where(date:lesson_time.date, state:'Not Available')
    overlapping_full_day_blocks = self.find_full_day_blocks(lesson_time)
    return same_slot_blocks + overlapping_full_day_blocks
  end

  def self.find_full_day_blocks(lesson_time)
    blocks = CalendarBlock.where(date:lesson_time.date, state:'Not Available')
  end

  # Old blocking logic that allowed instructors to block only specific slots
  # def self.find_all_calendar_blocks_in_day(lesson_time)
    # matching_lesson_times = LessonTime.where(date:lesson_time.date)
    # return [] if matching_lesson_times.nil?
    # calendar_blocks = []
    # matching_lesson_times.each do |lt|
    #   blocks_at_lt = CalendarBlock.where(lesson_time_id:lt.id)
    #   blocks_at_lt.each do |block|
    #     calendar_blocks << block
    #   end
    # end
    # return calendar_blocks
    # calendar_blocks = CalendarBlock.where(date:lesson_time.date)
  # end

  def self.booked_instructors(lesson_time)
    puts "checking for booked instructors on #{lesson_time.date} during the #{lesson_time.slot} slot"
    if lesson_time.slot == 'Full-day (10:00am-4:00pm)'
      booked_lessons = Lesson.select{|lesson| lesson.date == lesson_time.date && lesson.booked? && lesson.lesson_time.slot != '1hr Early Bird 8:45-9:45am'}
    else
      # this logic needs to be entirely re-worked now that we have 1hr lessons which overlap with half-days
      # booked_lessons = Lesson.select{|lesson| lesson.date == lesson_time.date && lesson.product && lesson.product.start_time == lesson_time.start_time}
      booked_lessons = Lesson.select{|lesson| lesson.date == lesson_time.date && lesson.booked? }
    end
    puts "There is/are #{booked_lessons.count} lesson(s) already booked at this time."
    booked_instructors = []
    booked_lessons.each do |lesson|
      if lesson.instructor_id
        booked_instructors << lesson.instructor
      end
    end
    return booked_instructors
  end

  def self.count_students_on_date(date)
    lessons = Lesson.all.select{|lesson| lesson.lesson_time.date.to_s == date }
    lessons = lessons.select{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.booked? || lesson.airbnb? || lesson.partially_booked? || lesson.state.nil? }
    count = 0
    lessons.each do |lesson|
      count += lesson.students.count
    end
    return count
  end

  # def self.find_booked_lessons(lesson_time)
  #   lessons_in_same_slot = Lesson.where('lesson_time_id = ?', lesson_time.id)
  #   overlapping_full_day_lessons = self.find_full_day_lessons(lesson_time)
  #   return lessons_in_same_slot + overlapping_full_day_lessons
  # end

  # def self.find_full_day_lessons(full_day_lesson_time)
  #   return [] unless full_day_lesson_time = LessonTime.find_by_date_and_slot(full_day_lesson_time.date,'Full-day (10am-4pm)')
  #   booked_lessons = []
  #   lessons_on_same_day = Lesson.where("lesson_time_id=? AND instructor_id is not null",full_day_lesson_time.id)
  #     lessons_on_same_day.each do |lesson|
  #       booked_lessons << lesson
  #       # puts "added a booked lesson to the booked_lesson set"
  #     end
  #   puts "After searching for other full-day lessons on this date, we found a total of #{booked_lessons.count} other lessons on this date."
  #   return booked_lessons
  # end

  # def self.find_all_booked_lessons_in_day(full_day_lesson_time)
  #   matching_lesson_times = LessonTime.where("date=?",full_day_lesson_time.date)
  #   # puts "------there are #{matching_lesson_times.count} matched lesson times on this date."
  #   booked_lessons = []
  #   matching_lesson_times.each do |lt|
  #     lessons_at_lt = Lesson.where("lesson_time_id=? AND instructor_id is not null",lt.id)
  #     lessons_at_lt.each do |lesson|
  #       booked_lessons << lesson
  #     end
  #   end
  #   # puts "After searching through the matching lesson times on this date, the booked lesson count on this day is now: #{booked_lessons.count}"
  #   return booked_lessons
  # end

  def send_sms_reminder_to_instructor_complete_lessons
      # ENV variable to toggle Twilio on/off during development
      return if ENV['twilio_status'] == "inactive"
      return if self.sms_notification_status == 'disabled'
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      recipient = self.instructor.phone_number
      body = "Hope you had a great Snow Schoolers lesson. Please confirm the start/end times and complete feedback for your student by visiting the lesson page at #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm."
      @client = Twilio::REST::Client.new account_sid, auth_token
          @client.api.account.messages.create({
          :to => recipient,
          :from => "#{snow_schoolers_twilio_number}",
          :body => body
      })
      # send_reminder_sms
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver!
  end

  def send_sms_day_before_reminder_to_instructor
      # ENV variable to toggle Twilio on/off during development
      return if ENV['twilio_status'] == "inactive"
      return if self.sms_notification_status == 'disabled'
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      recipient = self.instructor.phone_number
      body = "Reminder! You're scheduled for a lesson with #{self.requester_name} at #{self.product.start_time} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name}. Their number is #{self.phone_number.gsub(/[^0-9a-z ]/i,"")}. They are a level #{self.level.to_s} #{self.athlete}. Please remember to call them the night before to introduce yourself. You can view the full lesson details at #{ENV['HOST_DOMAIN']}/lessons/#{self.id}."
      @client = Twilio::REST::Client.new account_sid, auth_token
          @client.api.account.messages.create({
          :to => recipient,
          :from => "#{snow_schoolers_twilio_number}",
          :body => body
      })
      # send_reminder_sms
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver!
  end

  def send_sms_to_instructor
      return if ENV['twilio_status'] == "inactive"
      return if self.sms_notification_status == 'disabled'
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      first_instructor = self.available_instructors.any? ? self.available_instructors[0..3].sample : Instructor.where(username:"brian@snowschoolers.com").first
      instructor_id = first_instructor.id
      recipient = first_instructor.phone_number ? first_instructor.phone_number : "4083152900"
      case self.state
        when 'new'
          body = "A lesson booking was begun and not finished. Please contact an admin or email hello@snowschoolers.com if you intended to complete the lesson booking."
        when 'booked'
          body = "#{first_instructor.first_name}, You have a new lesson request from #{self.requester.name} at #{self.product.start_time} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name}. They are a level #{self.level.to_s} #{self.athlete}. Are you available? Please visit #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm."
        when 'seeking replacement instructor'
          body = "We need your help! Another instructor unfortunately had to cancel. Are you available to teach #{self.requester.name} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name} at #{self.product.start_time}? Please visit #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm."
        when 'pending instructor'
          body =  "#{self.available_instructors.first.first_name}, There has been a change in your previously confirmed lesson request. #{self.requester.name} would now like their lesson to be at #{self.product.start_time} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name}. Are you still available? Please visit #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm."
        when 'Lesson Complete'
          if self.transactions.last.tip_amount == 0.0009
            body = "#{self.requester.name} has completed their lesson review and reported that they gave you a cash tip. Great work!"
          elsif self.transactions.last.tip_amount == 0
            body = "Hope you had a great lesson with #{self.requester.name}. They have now completed their lesson review, which you should receive an email notification about shortly."
          else
            body = "#{self.requester.name} has completed payment for their lesson and you've received a tip of $#{self.post_stripe_tip.round(2)}. Great work!"
          end
      end
      @client = Twilio::REST::Client.new account_sid, auth_token
          @client.api.account.messages.create({
          :to => recipient,
          :from => "#{snow_schoolers_twilio_number}",
          :body => body
      })
      send_reminder_sms
      # puts "!!!!Body: #{body}"
      puts "!!!!!sorted instructors, and randomly chose one of top 4 ranked instructors to send SMS to. thise time chose #{first_instructor.name}."
      puts "!!!!! - reminder SMS has been scheduled"
      LessonMailer.notify_admin_sms_logs(self,recipient,body,instructor_id).deliver!
  end

  def send_reminder_sms
    # ENV variable to toggle Twilio on/off during development
    return if ENV['twilio_status'] == "inactive"
    return if self.sms_notification_status == 'disabled'
    return if self.state == 'confirmed'
    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_AUTH']
    snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
    recipient = self.available_instructors.any? ? self.available_instructors.first.phone_number : "4083152900"
    body = "#{self.available_instructors.first.first_name}, it has been #{(ENV['TWILIO_SMS_DELAY'].to_f/60.0).ceil} minutes and you have not accepted or declined this request. We are now making this lesson available to other instructors. You may still visit #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm the lesson."
    @client = Twilio::REST::Client.new account_sid, auth_token
          @client.api.account.messages.create({
          :to => recipient,
          :from => "#{snow_schoolers_twilio_number}",
          :body => body
      })
      puts "!!!!! - reminder SMS has been sent"
      send_sms_to_all_other_instructors
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver!
  end
  handle_asynchronously :send_reminder_sms, :run_at => Proc.new {ENV['TWILIO_SMS_DELAY'].to_i.seconds.from_now }

  def send_sms_to_all_other_instructors
    # ENV variable to toggle Twilio on/off during development
    return if ENV['twilio_status'] == "inactive"
    return if self.sms_notification_status == 'disabled'
    recipients = self.available_instructors
    recipients.each do |instructor|
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      body = "#{instructor.first_name}, #{self.requester.name} wants a lesson at #{self.product.start_time} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name}. Are you free? The lesson is now available to the first instructor that claims it by visiting #{ENV['HOST_DOMAIN']}/lessons/#{self.id} and accepting the request."
      @client = Twilio::REST::Client.new account_sid, auth_token
            @client.api.account.messages.create({
            :to => instructor.phone_number,
            :from => "#{snow_schoolers_twilio_number}",
            :body => body
        })
    end
    LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver!
  end
  handle_asynchronously :send_sms_to_all_other_instructors, :run_at => Proc.new {ENV['TWILIO_SMS_DELAY'].to_i.seconds.from_now }

  def send_manual_sms_request_to_instructor(instructor)
      # ENV variable to toggle Twilio on/off during development
      return if ENV['twilio_status'] == "inactive"
      return if self.sms_notification_status == 'disabled'
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      recipient = instructor.phone_number
      body = "Hi #{instructor.first_name}, we have a customer who is eager to find a #{self.activity} instructor. #{self.requester.name} wants a lesson at #{self.product.start_time} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name}. Are you available? The lesson is now available to the first instructor that claims it by visiting #{ENV['HOST_DOMAIN']}/lessons/#{self.id} and accepting the request."
      @client = Twilio::REST::Client.new account_sid, auth_token
          @client.api.account.messages.create({
          :to => recipient,
          :from => "#{snow_schoolers_twilio_number}",
          :body => body
      })
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver!
  end

  def send_sms_to_requester
      # ENV variable to toggle Twilio on/off during development
      return if ENV['twilio_status'] == "inactive"
      return if self.sms_notification_status == 'disabled'
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      recipient = self.phone_number.gsub(/[^0-9a-z ]/i,"")
      case self.state
        when 'confirmed'
        body = "Congrats! Your Snow Schoolers lesson has been confirmed. #{self.instructor.name} will be your instructor at #{self.location.name} on #{self.lesson_time.date.strftime("%b %d")} at #{self.product.start_time}. Please check your email for more details about meeting location & to review your pre-lesson checklist."
        when 'seeking replacement instructor'
        body = "Bad news! Your instructor has unfortunately had to cancel your lesson. Don't worry, we are finding you a new instructor right now."
        when 'waiting for review'
        body = "We hope you had a great lesson with #{self.instructor.name}! You may now complete the lesson experience online and leave a quick review for #{self.instructor.first_name} by visiting #{ENV['HOST_DOMAIN']}/lessons/#{self.id}. Thanks for using Snow Schoolers!"
      end
      if recipient.length == 10 || recipient.length == 11
        @client = Twilio::REST::Client.new account_sid, auth_token
            @client.api.account.messages.create({
            :to => recipient,
            :from => "#{snow_schoolers_twilio_number}",
            :body => body
        })
          LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver!
          else
            puts "!!!! error - could not send SMS via Twilio"
            LessonMailer.send_admin_notify_invalid_phone_number(self).deliver!
        end
  end

  def send_sms_to_admin
      return if ENV['twilio_status'] == "inactive"
      return true if self.skip_validations
      recipient = "408-315-2900"
      body = "ALERT - no instructors are available to teach #{self.requester.name} at #{self.product.start_time} on #{self.lesson_time.date} at #{self.location.name}. The last person to decline was #{Instructor.find(LessonAction.last.instructor_id).username}."
      @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']
      ADMIN_PHONE_NUMBERS.each do |recipient|
          @client.api.account.messages.create({
          :to => recipient,
          :from => ENV['TWILIO_NUMBER'],
          :body => body
          })
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver!
      end
  end

  def notify_admin_private_lessons_sold_out(lesson_time,activity,guest_email)
      # lesson = Lesson.find(lesson_id)
      # recipient = "408-315-2900"
      return if ENV['twilio_status'] == "inactive"
      guest = guest_email ? guest_email : 'a new customer'
      body = "ALERT - #{guest} attempted to request a private #{activity} lesson on #{lesson_time.date}. The lesson is a #{lesson_time.slot}. We have no more instructors available based on the current calendar. We must activate more instructors before selling additional lessons at this time."
      @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']    
      ADMIN_PHONE_NUMBERS.each do |recipient|
          @client.api.account.messages.create({
          :to => recipient,
          :from => ENV['TWILIO_NUMBER'],
          :body => body
          })
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver!
      end
  end

  def notify_admin_group_lessons_sold_out(lesson_time,activity,guest_email)
      return if ENV['twilio_status'] == "inactive"
      recipient = "408-315-2900"
      guest = guest_email ? guest_email : 'a new customer'
      body = "ALERT - #{guest} attempted to request a group #{activity} lesson on #{lesson_time.date}. The lesson is a #{lesson_time.slot}. We have no more instructors available based on the current calendar. We must activate more instructors before selling additional lessons at this time."
      @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']
      ADMIN_PHONE_NUMBERS.each do |recipient|
          @client.api.account.messages.create({
          :to => recipient,
          :from => ENV['TWILIO_NUMBER'],
          :body => body
          })
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver!
      end
  end

  def send_sms_to_admin_1to1_request_failed
      @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']
          @client.api.account.messages.create({
          :to => "408-315-2900",
          :from => ENV['TWILIO_NUMBER'],
          :body => "ALERT - A private 1:1 request was made and declined. #{self.requester.name} had requested #{self.instructor.name} but they are unavailable at #{self.product.start_time} on #{self.lesson_time.date} at #{self.location.name}."
      })
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver!
  end

  def student_ids
    ids = []
    self.students.each do |student|
      ids << student.id
    end
    return ids
  end

  def create_rental_reservation
    return false if !self.includes_rental_package?
    return true if self.rentals.count == (self.students.count * 2)
    if self.activity == 'Ski'
      self.students.each do |student|
        Rental.find_or_create_by!({
          lesson_id: self.id,
          rental_date: self.date,
          resource_type: 'ski',
          student_id: student.id,
          status: 'not yet selected'
          })
        Rental.find_or_create_by!({
          lesson_id: self.id,
          rental_date: self.date,
          resource_type: 'ski_boot',
          student_id: student.id,
          status: 'not yet selected'
          })
      end
    else
      self.students.each do |student|
        Rental.find_or_create_by!({
          lesson_id: self.id,
          rental_date: self.date,
          resource_type: 'snowboard',
          student_id: student.id,
          status: 'booked, ready to process'
          })
        Rental.find_or_create_by!({
          lesson_id: self.id,
          rental_date: self.date,
          resource_type: 'snowboard_boot',
          student_id: student.id,
          status: 'booked, ready to process'
          })
      end
    end
  end


private

  def instructors_must_be_available
    return true if self.skip_validations
    return true if self.class_type == "tickets"
    puts "!!! checking if group class type"
    # don't automatically approve group lessons if private instructors are sold out
    # return true if group_lesson?
    if available_instructors?
      return true
    else
      errors.add(:lesson, "Error: unfortunately we are sold out of instructors at that time. Please choose another time slot, or contact us by phone at 530-430-SNOW or email hello@snowschoolers.com for the latest information on instructor availability.")
      notify_admin_private_lessons_sold_out(self.lesson_time, self.activity, self.guest_email)
      return false
    end
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
    return true if group_lesson? || excluded_lesson?
    if self.active? && self.product && self.confirmable? && self.deposit_status == 'confirmed' && self.state != "pending instructor" && self.email_notifications_status != 'disabled'
      LessonMailer.send_lesson_request_to_instructors(self).deliver!
      puts "!!!!!lesson email sent to all available instructors"
      self.send_sms_to_instructor
    elsif self.available_instructors.any? == false
      self.send_sms_to_admin
    end
  end

  def no_instructors_post_instructor_drop?
    pending_requester?
  end
end
