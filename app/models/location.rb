require 'csv'

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

  def self.import(file)
    CSV.foreach(file.path, headers:true) do |row|
      if Location.where(id:row.id).length == 0
        Location.create!(row.to_hash)
        puts "new product created with name: #{Product.last.name}"
      end
    end
  end

  def self.to_csv(options = {})
    desired_columns = %w{ id name partner_status calendar_status region state vertical_feet base_elevation peak_elevation skiable_acres average_snowfall lift_count address
    }
    CSV.generate(headers: true) do |csv|
      csv << desired_columns
      all.each do |location|
        csv << location.attributes.values_at(*desired_columns)
      end
    end
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
