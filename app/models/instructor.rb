class Instructor < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :ski_levels
  has_and_belongs_to_many :snowboard_levels
  has_many :lesson_actions
  has_many :lessons
  has_and_belongs_to_many :sports
  has_many :reviews
  has_many :calendar_blocks
  has_many :sections
  after_create :send_admin_notification
  validates :username, :first_name, :last_name, :certification, :intro, presence: true
  has_attached_file :avatar, styles: { large: "400x400>", thumb: "80x80>" },  default_url: "https://s3.amazonaws.com/snowschoolers/cd-sillouhete.jpg",
        :storage => :s3,
        :bucket => 'snowschoolers'
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  def days_available
    CalendarBlock.where(instructor_id:self.id,state:'Available').count
  end

  def days_booked
    CalendarBlock.where(instructor_id:self.id,state:'Booked').count
  end

  def email
    self.user ? self.user.email : self.username
  end

  def mark_eligible_for_beginners
    self.ski_level_ids = [1,2,3,4]
    self.snowboard_level_ids = [1,2,3,4]        
  end

  def prime_days_available
    CalendarBlock.where(instructor_id:self.id,prime_day:true,state:'Available').count
  end

  def prime_days_booked
    CalendarBlock.where(instructor_id:self.id,prime_day:true,state:'Booked').count
  end

  def total_days
    self.days_available + self.days_booked
  end

  def total_prime_days
    self.prime_days_available + self.prime_days_booked
  end

  def completed_lessons_count
    Lesson.where(state:'Lesson Complete',instructor_id:self.id).count
  end

  def wage_rate
    self.base_rate ? self.base_rate : 16
  end

  def raw_wages_this_season
    lessons = Lesson.select{|lesson| lesson.eligible_for_payroll? && lesson.instructor_id == self.id }
    wages = 0
    lessons.each do |lesson|
        wages += lesson.wages
    end
    return wages
  end

  def bonus_wages_this_season
    lessons = Lesson.select{|lesson| lesson.eligible_for_payroll? && lesson.instructor_id == self.id }
    bonus_wages = 0
    lessons.each do |lesson|
        bonus_wages += lesson.bonus_wages
    end
    return bonus_wages
  end

  def paid_wages_to_date
    lessons = Lesson.select{|lesson| lesson.eligible_for_payroll? && lesson.payment_status == "Paid"}
    wages = 0
    lessons.each do |lesson|
        wages += lesson.wages
    end
    return wages
  end

  def total_tips
    lessons = Lesson.where(state:'Lesson Complete',instructor_id:self.id)
    tips = 0
    lessons.each do |lesson|
        tips += lesson.tip.to_f
    end
    return tips
  end

  def total_earnings
    self.total_wages + self.total_tips
  end


  def self.scheduled_for_date(date)
    eligible_shifts = Shift.all.to_a.keep_if {|shift| shift.start_time.to_date == date}
    eligible_shifts = eligible_shifts.keep_if { |shift| shift.status == "Scheduled" || shift.status == "Assigned"}
    instructors = []
    eligible_shifts.each do |shift|
      instructors << Instructor.find(shift.instructor_id)
    end
    return instructors
  end

  def self.create_default_bios
    Instructor.all.each do |instructor|
      if instructor.bio.nil?
      instructor.bio = "TBD - PSIA Level 1 certified instructor."
      instructor.save
      end
    end
  end

  def self.active_instructors
    Instructor.where(status:'Active')
  end

  def self.seed_temp_instructors
    first_names = ['Jim','Garry','Steven','Adam','Kelly','Natalie','Anita','Connie','Brian','Chris','Christian','Andrew','Ryan','Seth','Justin','Michael','Cameron','Cindy','Ryan','Jerry']
    last_names =  ['Kinney','Cox','Church','Garon','Larson','Barros','Hill','Wang','Bensch','Prattis','Herlihy','Eells','Hoben','Evanhoe','Palmer','Beler','Ulhriy','Palfy','Walker','Jones']
    (0..9).to_a.each do |number|
      Instructor.create!({
        first_name: first_names[number],
        last_name: last_names[number],
        username: "test_user@snowschoolers.com",
        certification: ['Level 1', 'Level 2', 'Level 3', 'HTA'].sample,
        phone_number: "408-315-2900",
        bio: Faker::Hipster.paragraph,
        intro: Faker::StarWars.quote,
        status: "Active",
        adults_initial_rank: (1..10).to_a.sample,
        kids_initial_rank: (1..10).to_a.sample,
        overall_initial_rank: (1..10).to_a.sample,
        city: "Tahoe City",
        confirmed_certification: "True",
        kids_eligibility: true,
        seniors_eligibility: true,
        adults_eligibility: true,        
        age: (18..50).to_a.sample,
        dob: nil,
        ski_level_ids: [[1,2,3,4],[1,2,3,4,5,6,7],[1,2,3,4,5,6,7,8,9]].sample,
        snowboard_level_ids: [[1,2,3,4],[1,2,3,4,5,6,7],[1,2,3,4,5,6,7,8,9]].sample,
        location_ids: 8
        })
    end
    Instructor.all.each do |instructor|
        instructor.sport_ids =  [[1,2],[1],[2]].sample
        instructor.save!        
    end
  end

  def ski_instructor?
    return true if self.sports.include?(Sport.where(name:"Ski Instructor").first)
  end

  def snowboard_instructor?
    return true if self.sports.include?(Sport.where(name:"Snowboard Instructor").first)
  end

  def telemark_instructor?
    return true if self.sports.include?(Sport.where(name:"Telemark Instructor").first)
  end

  def average_rating
    return 5 if reviews.count == 0
    total_stars = 0
    if self.reviews.count > 0
    self.reviews.each do |review|
        unless review.rating.nil?
          total_stars += review.rating
        end
      end
    end
    return (total_stars.to_f / self.reviews.count.to_f)
  end

  def completed_lessons
    self.lessons.where(state:'Completed')
  end

  def kids_score
    kids_lessons = self.completed_lessons.to_a.keep_if {|lesson| lesson.kids_lesson? }
    points_for_completed_lessons = kids_lessons.count * 10
    points_for_5star_reviews = 0
    points_for_acceptenace_rate = 0
    total_points = self.kids_initial_rank + points_for_completed_lessons + points_for_5star_reviews + points_for_acceptenace_rate
  end

  def seniors_score
    seniors_lessons = self.completed_lessons.to_a.keep_if {|lesson| lesson.seniors_lesson? }
    points_for_completed_lessons = seniors_lessons.count * 10
    points_for_5star_reviews = 0
    points_for_acceptenace_rate = 0
    total_points = self.adults_initial_rank + points_for_completed_lessons + points_for_5star_reviews + points_for_acceptenace_rate
  end

  def overall_score
    points_for_completed_lessons = self.completed_lessons.count * 10
    points_for_5star_reviews = 0
    points_for_acceptenace_rate = 0
    total_points = self.overall_initial_rank + points_for_completed_lessons + points_for_5star_reviews + points_for_acceptenace_rate
  end

  def name
    self.first_name + " " + self.last_name
  end

  def to_param
      # [id,name.parameterize].join("-")
      name.parameterize
  end

  # Hacky flag -- may want to remove this
  def self.from_param(param)
    find_by!(param)
  end

  def send_admin_notification
      @instructor = Instructor.last
      if @instructor.bio == "hta_candidate"
        LessonMailer.new_hta_application_received(@instructor).deliver!
        LessonMailer.send_hta_application_confirmation(@instructor).deliver!
      else
        LessonMailer.new_instructor_application_received(@instructor).deliver!
        LessonMailer.send_new_instructor_application_confirmation(@instructor).deliver!
        puts "an admin notification has been sent."
      end
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
      return 'From a Flyer'
    when 5
      return 'Linkedin'
    when 100
      return 'Other'
    end
  end


end
