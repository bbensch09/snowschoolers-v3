class Review < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id'
  belongs_to :lesson
  # after_save :send_admin_notification


  def display_name
    if self.reviewer.email == "brian@snowschoolers.com"
        sample_names = ['Ken','Bryan','Don','Carl','Bob','Aaron','Ashley','Kevin','Robert','Tessa','Gary','Dee','Ryan','Sean']
        return sample_names[rand(14)]
    elsif self.lesson && self.lesson.requester_name
      return self.lesson.requester_name.split(" ").first
    else
      return "Anonymous"
    end
  end

  def self.average_rating
    @reviews = Review.all.to_a.keep_if { |review| review.lesson_id != nil}
    cumulative_review_score = 0
    @reviews.each do |review|
      cumulative_review_score += review.rating
    end
    avg_rating = (cumulative_review_score.to_f / @reviews.count.to_f)
    return (avg_rating*100).round / 100.0
  end

  def self.nps_eligible
    @reviews = Review.all.to_a.keep_if { |review| review.nps != nil}
  end

  def self.average_nps
    @reviews = Review.nps_eligible
    detractors = []
    neutrals = []
    promoters = []
    @reviews.each do |review|
      if review.nps <=6
        detractors << review
      elsif review.nps <=8
        neutrals << review
      else
        promoters << review
      end
    end
    detractors_percent = (detractors.count.to_f / @reviews.count)
    puts "!!!!!!! Detractors percent is #{detractors_percent}"
    neutral_percent = (neutrals.count.to_f / @reviews.count)
    puts "!!!!!!! Neutral percent is #{neutral_percent}"
    promoters_percent = (promoters.count.to_f / @reviews.count)
    puts "!!!!!!! Promoters percent is #{promoters_percent}"
    nps = (promoters_percent*100 - detractors_percent*100).to_i
  end

  def send_admin_notification
    LessonMailer.new_review_submitted(@review).deliver
  end

end
