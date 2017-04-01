class Section < ApplicationRecord
	has_many :lessons
	belongs_to :sport
	belongs_to :instructor

	def name
		return "#{self.age_group} #{self.lesson_type} - #{self.sport.activity_name}"
	end

	def student_count
		Lesson.where(section_id:self.id).count
	end

	def remaining_capacity
		self.capacity - self.student_count
	end

end
