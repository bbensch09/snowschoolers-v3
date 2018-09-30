class Rental < ApplicationRecord
	belongs_to :lesson
	belongs_to :student
	has_one :resource

def max_size
	case self.resource_type
	when 'ski'
		then self.student.max_ski_length.to_s
	when 'snowboard'
		then self.student.max_sb_length.to_s
	end			
end

def min_size
	case self.resource_type
	when 'ski'
		then self.student.min_ski_length.to_s
	when 'snowboard'
		then self.student.min_sb_length.to_s
	end			
end

def shoe_sizes
	self.student.eligible_shoe_sizes
end

end
