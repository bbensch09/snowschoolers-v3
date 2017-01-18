class Review < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id'
  belongs_to :lesson

  def display_name
    if self.reviewer.email == "brian@snowschoolers.com" && self.lesson && self.lesson.guest_email
      return self.lesson.requester_name
    else
      return self.reviewer.display_name
    end
  end

end
