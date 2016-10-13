class Location < ActiveRecord::Base
  has_and_belongs_to_many :instructors  #, dependent: :destroy
  has_one :user
  has_many :products

  def lifetime_lessons
    Lesson.where(state:"Payment Complete",requested_location:self.id.to_s)
  end

  def lifetime_revenue
    lessons = self.lifetime_lessons
    revenue = 0
    lessons.each do |lesson|
      revenue += lesson.price
    end
    return revenue
  end

  def upcoming_lessons
  end

  def upcoming_revenue
  end

  def today_lessons
      lessons = lifetime_lessons
      lessons.keep_if {|lesson| lesson.lesson_time.date == Date.today }
  end

  def today_revenue
    lessons = self.today_lessons
    revenue = 0
    lessons.each do |lesson|
      revenue += lesson.price
    end
    return revenue
  end

end
