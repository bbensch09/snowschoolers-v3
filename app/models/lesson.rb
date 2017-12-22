class Lesson < ActiveRecord::Base
  belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'
  belongs_to :instructor
  belongs_to :lesson_time
  has_many :students
  has_one :review
  has_many :transactions
  has_many :lesson_actions
  belongs_to :product #, class_name: 'Product', foreign_key: 'product_id'
  belongs_to :section
  accepts_nested_attributes_for :students, reject_if: :all_blank, allow_destroy: true

  validates :requested_location, :lesson_time, presence: true
  validates :phone_number,
            presence: true, on: :update
  # validates :duration, :start_time, presence: true, on: :update
  # validates :gear, inclusion: { in: [true, false] }, on: :update #gear now moved to student section
  validates :terms_accepted, inclusion: { in: [true], message: 'must accept terms' }, on: :update
  validates :actual_start_time, :actual_end_time, presence: true, if: :just_finalized?
  # validate :requester_must_not_be_instructor, on: :create
  validate :lesson_time_must_be_valid
  validate :student_exists, on: :update

  #Check to ensure an instructor is available before booking
  validate :instructors_must_be_available, on: :create
  after_save :send_lesson_request_to_instructors
  before_save :calculate_actual_lesson_duration, if: :just_finalized?

  def confirmation_number
    date = self.lesson_time.date.to_s.gsub("-","")
    date = date[4..-1]
    case self.location.name
      when 'Granlibakken'
        l = 'GB'
      when 'Homewood'
        l = 'HW'
      else
        l = 'XX'
    end
    id = self.id.to_s
    confirmation_number = l+'-'+date+'-'+id
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
        slot: ['Early Bird (9-10am)', 'Half-day Morning (10am-1pm)', 'Half-day Afternoon (1pm-4pm)','Full-day (10am-4pm)', 'Mountain Rangers All-day', 'Snow Rangers All-day'].sample
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
    case self.lesson_time.slot
      when SLOTS.first
        return "1.00"
      when SLOTS.second
        return "3.00"
      when SLOTS.third
        return "3.00"
      when SLOTS.fourth
        return "6.00"
      end
  end

  def product
    if self.product_id.nil?
      calendar_period = self.lookup_calendar_period(self.lesson_time.date,self.location.id)
      if self.requested_location == "8"
        Product.where(location_id:self.location.id, name:self.lesson_time.slot,is_private_lesson:true,calendar_period:calendar_period).first
      elsif self.requested_location == "24"
        Product.where(location_id:self.location.id, length:self.length,is_private_lesson:true,calendar_period:calendar_period).first
      end                  
    else
      Product.where(id:self.product_id).first
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

  def wages
    instructor = self.instructor
    if instructor
      wages = self.product.length.to_i * instructor.wage_rate
    else
      wages = self.product.length.to_i * 16
    end
  end

  def self.total_prime_days
    total = 0
    Instructor.active_instructors.each do |instructor|
      total += instructor.prime_days_available
      total += instructor.prime_days_booked
    end
    return total
  end

  def this_season?
    self.lesson_time.date.to_s >= '2017-12-15'
  end
  
  def last_season?
    self.lesson_time.date.to_s <= '2017-04-30'
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

  def self.open_lesson_requests
    lessons = Lesson.where(state:'booked',instructor_id:nil) 
    lessons.select{|lesson| lesson.this_season?}
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
    Location.find(self.requested_location.to_i)
  end

  def active?
    active_states = ['new', 'booked', 'confirmed','pending instructor','gift_voucher_reserved','pending requester','']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    active_states.include?(state)
  end

  def active_today?
    active_states = ['confirmed','seeking replacement instructor','pending instructor', 'pending requester','Lesson Complete','finalizing payment & reviews','waiting for review','finalizing','ready_to_book']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    return true if self.date == Date.today && active_states.include?(state)
  end

  def upcoming?
    active_states = ['new','booked','confirmed','seeking replacement instructor','pending instructor', 'pending requester','Lesson Complete','finalizing payment & reviews','waiting for review','finalizing','ready_to_book']
    return true if active_states.include?(state) && self.date > Date.today
  end

  def confirmable?
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
    state == 'finalizing payment & reviews'
  end

  def waiting_for_review?
    state == 'Payment complete, waiting for review.'
  end

  def completed?
    active_states = ['finalizing','finalizing payment & reviews','Payment complete, waiting for review.','Lesson Complete']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    active_states.include?(state)
  end

  def payment_complete?
    state == 'Payment complete, waiting for review.' || state == 'Lesson Complete'
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
    puts "!!!! calculating price"
    if self.product_name
      puts "!!!calculating price based on product name, location, and date"
      calendar_period = self.lookup_calendar_period(self.lesson_time.date,self.location.id)
      puts "!!!!lookup calendar period status, it is: #{calendar_period}"
      #pricing for GB lesson package
      if self.slot == 'Early Bird (9-10am)' && self.location.id == 24 && self.includes_rental_package?
        product = Product.where(location_id:self.location.id,length:"1.00",calendar_period:calendar_period,name:'1hr Private Lesson Package',product_type:"private_lesson").first
      #pricing for GB lesson only
      elsif self.slot == 'Early Bird (9-10am)' && self.location.id == 24 && !self.includes_rental_package?
        product = Product.where(location_id:self.location.id,length:"1.00",calendar_period:calendar_period,name:'1hr Private Lesson (lesson + lift only)',product_type:"private_lesson").first
      #pricing for HW lesson
      elsif self.slot == 'Early Bird (9-10am)'
        product = Product.where(location_id:self.location.id,length:"1.00",calendar_period:calendar_period,product_type:"private_lesson").first
      #pricing for GB half-day package
      elsif self.slot.starts_with?('Half-day') && self.location.id == 24 && self.includes_rental_package?
        product = Product.where(location_id:self.location.id,length:"3.00",calendar_period:calendar_period,name:'Half-day Morning Package (3hr)',product_type:"private_lesson").first
      #pricing for GB half-day lesson only
      elsif self.slot.starts_with?('Half-day') && self.location.id == 24 && !self.includes_rental_package?
        product = Product.where(location_id:self.location.id,length:"3.00",calendar_period:calendar_period,name:'Half-day Morning Private Lesson (no rental)',product_type:"private_lesson").first
      #pricing for HW half-day lesson
      elsif self.slot.starts_with?('Half-day')
        product = Product.where(location_id:self.location.id,length:"3.00",calendar_period:calendar_period,product_type:"private_lesson").first
      #pricing for GB full-day lesson package
      elsif self.slot == 'Full-day (10am-4pm)'  && self.location.id == 24 && self.includes_rental_package?
        product = Product.where(location_id:self.location.id,length:"6.00",calendar_period:calendar_period,name:'Full-day Private Lesson Package (6hr)',product_type:"private_lesson").first
      #pricing for GB full-day lesson only
      elsif self.slot == 'Full-day (10am-4pm)' && self.location.id == 24 && !self.includes_rental_package?
        product = Product.where(location_id:self.location.id,length:"6.00",calendar_period:calendar_period,name:'Full-day Private Lesson (no rental)',product_type:"private_lesson").first
      #pricing for HW full-day lesson
      elsif self.slot == 'Full-day (10am-4pm)'
        product = Product.where(location_id:self.location.id,length:"6.00",calendar_period:calendar_period,product_type:"private_lesson").first
      end
      puts "!!!product found, its price is #{product.price}"
    end
    if product.nil?
      return "Please confirm date & time to see price."
    end
    price = product.price.to_f + self.package_cost
    return price.to_f
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
            product = Product.where(length:"3.00",location_id:self.location.id,calendar_period:calendar_period,product_type:"private_lesson").first
          when "extend_half_day_to_full"
            product = Product.where(length:"6.00",location_id:self.location.id,calendar_period:calendar_period,product_type:"private_lesson").first
          when "extend_early_bird_to_full"
            product = Product.where(length:"6.00",location_id:self.location.id,calendar_period:calendar_period,product_type:"private_lesson").first
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
    return 0 if self.students.count == 0
    package_price = 0
    puts "!!!calculating package cost"
    p1 = self.additional_students_with_gear.to_i * self.cost_per_additional_student_with_gear
    p2 = self.additional_students_without_gear.to_i * self.cost_per_additional_student_without_gear
    package_price = p1 + p2    
  end

  def cost_per_additional_student_with_gear
    case self.location.id
      when 24
        return 65
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

  def athlete
    if self.activity == "Ski"
      return "skier"
    else
      return "snowboarder"
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
    available_instructors.any? ? true : false
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
    if lesson_time.slot == 'Full-day (10am-4pm)'
      booked_lessons = Lesson.select{|lesson| lesson.date == lesson_time.date}
    else
      booked_lessons = Lesson.select{|lesson| lesson.date == lesson_time.date && lesson.lesson_time.slot == lesson_time.slot}
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
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver
  end

  def send_sms_to_instructor
      return if ENV['twilio_status'] == "inactive"
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      first_instructor = self.available_instructors.any? ? self.available_instructors[0..3].sample : "Admin"
      recipient = first_instructor.phone_number ? first_instructor.phone_number : "4083152900"
      case self.state
        when 'new'
          body = "A lesson booking was begun and not finished. Please contact an admin or email info@snowschoolers.com if you intended to complete the lesson booking."
        when 'booked'
          body = "#{self.available_instructors.first.first_name}, You have a new lesson request from #{self.requester.name} at #{self.product.start_time} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name}. They are a level #{self.level.to_s} #{self.athlete}. Are you available? Please visit #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm."
        when 'seeking replacement instructor'
          body = "We need your help! Another instructor unfortunately had to cancel. Are you available to teach #{self.requester.name} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name} at #{self.product.start_time}? Please visit #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm."
        when 'pending instructor'
          body =  "#{self.available_instructors.first.first_name}, There has been a change in your previously confirmed lesson request. #{self.requester.name} would now like their lesson to be at #{self.product.start_time} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name}. Are you still available? Please visit #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm."
        when 'Payment complete, waiting for review.'
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
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver
  end

  def send_reminder_sms
    # ENV variable to toggle Twilio on/off during development
    return if ENV['twilio_status'] == "inactive"    
    return if self.state == 'confirmed'
    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_AUTH']
    snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
    recipient = self.available_instructors.any? ? self.available_instructors.first.phone_number : "4083152900"
    body = "#{self.available_instructors.first.first_name}, it has been over #{ENV['TWILIO_SMS_DELAY']} minutes and you have not accepted or declined this request. We are now making this lesson available to other instructors. You may still visit #{ENV['HOST_DOMAIN']}/lessons/#{self.id} to confirm the lesson."
    @client = Twilio::REST::Client.new account_sid, auth_token
          @client.api.account.messages.create({
          :to => recipient,
          :from => "#{snow_schoolers_twilio_number}",
          :body => body
      })
      puts "!!!!! - reminder SMS has been sent"
      send_sms_to_all_other_instructors
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver
  end
  handle_asynchronously :send_reminder_sms, :run_at => Proc.new {ENV['TWILIO_SMS_DELAY'].to_i.seconds.from_now }

  def send_sms_to_all_other_instructors
    # ENV variable to toggle Twilio on/off during development
    return if ENV['twilio_status'] == "inactive"    
    recipients = self.available_instructors
    # if recipients.count < 2
    #   @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']
    #       @client.api.account.messages.create({
    #       :to => "408-315-2900",
    #       :from => ENV['TWILIO_NUMBER'],
    #       :body => "ALERT - #{self.available_instructors.first.name} is the only instructor available and they have not responded after 10 minutes. No other instructors are available to teach #{self.requester.name} at #{self.product.start_time} on #{self.lesson_time.date} at #{self.location.name}."
    #   })
    # end
    # identify recipients to be notified as all available instructors except for the first instructor, who has been not responsive
    recipients.each do |instructor|
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      body = "#{instructor.first_name}, we have a customer who is eager to find an instructor. #{self.requester.name} wants a lesson at #{self.product.start_time} on #{self.lesson_time.date.strftime("%b %d")} at #{self.location.name}. Are you available? The lesson is now available to the first instructor that claims it by visiting #{ENV['HOST_DOMAIN']}/lessons/#{self.id} and accepting the request."
      @client = Twilio::REST::Client.new account_sid, auth_token
            @client.api.account.messages.create({
            :to => instructor.phone_number,
            :from => "#{snow_schoolers_twilio_number}",
            :body => body
        })
    end
    LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver
  end
  handle_asynchronously :send_sms_to_all_other_instructors, :run_at => Proc.new {ENV['TWILIO_SMS_DELAY'].to_i.seconds.from_now }

  def send_manual_sms_request_to_instructor(instructor)
      # ENV variable to toggle Twilio on/off during development
      return if ENV['twilio_status'] == "inactive"
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
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver
  end

  def send_sms_to_requester
      # ENV variable to toggle Twilio on/off during development
      return if ENV['twilio_status'] == "inactive"    
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      recipient = self.phone_number.gsub(/[^0-9a-z ]/i,"")
      case self.state
        when 'confirmed'
        body = "Congrats! Your Snow Schoolers lesson has been confirmed. #{self.instructor.name} will be your instructor at #{self.location.name} on #{self.lesson_time.date.strftime("%b %d")} at #{self.product.start_time}. Please check your email for more details about meeting location & to review your pre-lesson checklist."
        when 'seeking replacement instructor'
        body = "Bad news! Your instructor has unfortunately had to cancel your lesson. Don't worry, we are finding you a new instructor right now."
        when 'finalizing payment & reviews'
        body = "We hope you had a great lesson with #{self.instructor.name}! You may now complete the lesson experience online and leave a quick review for #{self.instructor.first_name} by visiting #{ENV['HOST_DOMAIN']}/lessons/#{self.id}. Thanks for using Snow Schoolers!"
      end
      if recipient.length == 10 || recipient.length == 11
        @client = Twilio::REST::Client.new account_sid, auth_token
            @client.api.account.messages.create({
            :to => recipient,
            :from => "#{snow_schoolers_twilio_number}",
            :body => body
        })
          LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver
          else
            puts "!!!! error - could not send SMS via Twilio"
            LessonMailer.send_admin_notify_invalid_phone_number(self).deliver
        end
  end

  def send_sms_to_admin
      recipient = "408-315-2900"
      body = "ALERT - no instructors are available to teach #{self.requester.name} at #{self.product.start_time} on #{self.lesson_time.date} at #{self.location.name}. The last person to decline was #{Instructor.find(LessonAction.last.instructor_id).username}."
      @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']
          @client.api.account.messages.create({
          :to => recipient,
          :from => ENV['TWILIO_NUMBER'],
          :body => body
      })
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver
  end

  def send_sms_to_admin_1to1_request_failed
      @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']
          @client.api.account.messages.create({
          :to => "408-315-2900",
          :from => ENV['TWILIO_NUMBER'],
          :body => "ALERT - A private 1:1 request was made and declined. #{self.requester.name} had requested #{self.instructor.name} but they are unavailable at #{self.product.start_time} on #{self.lesson_time.date} at #{self.location.name}."
      })
      LessonMailer.notify_admin_sms_logs(self,recipient,body).deliver
  end

  private

  def instructors_must_be_available
    unless available_instructors.any?
      errors.add(:lesson, " unfortunately not available at that time. Please email info@snowschoolers.com to be notified if we have any instructors that become available.")
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
    if self.active? && self.confirmable? && self.deposit_status == 'confirmed' && self.state != "pending instructor" && self.available_instructors.any? #&& self.deposit_status == 'verified'
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
