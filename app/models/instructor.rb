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
  after_create :send_admin_notification
  validates :username, :first_name, :last_name, :certification, :intro, presence: true
  has_attached_file :avatar, styles: { large: "400x400>", thumb: "80x80>" },  default_url: "https://s3.amazonaws.com/snowschoolers/cd-sillouhete.jpg",
        :storage => :s3,
        :bucket => 'snowschoolers'
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  def self.scheduled_for_date(date)
    eligible_shifts = Shift.all.to_a.keep_if {|shift| shift.start_time.to_date == date}
    eligible_shifts = eligible_shifts.keep_if { |shift| shift.status == "Scheduled"}
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

  def self.seed_temp_instructors
    10.times do 
      Instructor.create!({
        first_name: ['Jim','Garry','Steven','Adam','Kelly','Natalie','Anita','Connie'].sample,
        last_name: "Smith",
        username: "test_user",
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
        dob: nil
        })
    end
    Instructor.all.each do |instructor|
        instructor.sport_ids =  [[1,3],[1],[3]].sample
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
    return 4 if reviews.count == 0
    total_stars = 0
    if self.reviews.count > 0
    self.reviews.each do |review|
      total_stars += review.rating
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
        [id, name.parameterize].join("-")
  end

  def send_admin_notification
      @instructor = Instructor.last
      LessonMailer.new_instructor_application_received(@instructor).deliver
      puts "an admin notification has been sent."
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
