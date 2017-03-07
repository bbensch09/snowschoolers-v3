class Location < ActiveRecord::Base
  has_and_belongs_to_many :instructors  #, dependent: :destroy
  has_one :user
  has_many :selfies
  has_many :products
  has_attached_file :logo, styles: { large: "400x400>", thumb: "80x80>" },  default_url: "https://s3.amazonaws.com/snowschoolers/cd-sillouhete.jpg",
        :storage => :s3,
        :bucket => 'snowschoolers'
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/


  def self.active_partners
    Location.where(partner_status:'Active')
  end

  def lifetime_lessons
    Lesson.where(requested_location:self.id.to_s).to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed?}
  end

  def lifetime_revenue
    lessons = self.lifetime_lessons
    revenue = 0
    lessons.each do |lesson|
      if lesson.lesson_cost?
          revenue += lesson.lesson_cost
        elsif lesson.lesson_price?
          revenue += lesson.lesson_price
        elsif lesson.price.class == Float
          revenue += lesson.price
      end
    end
    return revenue
  end

  def upcoming_lessons
  end

  def upcoming_revenue
  end

  def today_lessons
      lessons = Lesson.where(requested_location:self.id.to_s)
      lessons.to_a.keep_if {|lesson| lesson.lesson_time.date == Date.today && (lesson.completed? || lesson.completable?)}
  end

  def today_revenue
    lessons = self.today_lessons
    revenue = 0
    lessons.each do |lesson|
      if lesson.price.class == Float
        revenue += lesson.price
      end
    end
    return revenue
  end

end
