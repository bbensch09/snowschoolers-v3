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

  def self.create_default_bios
    Instructor.all.each do |instructor|
      if instructor.bio.nil?
      instructor.bio = "TBD - PSIA Level 1 certified instructor."
      instructor.save
      end
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

end
