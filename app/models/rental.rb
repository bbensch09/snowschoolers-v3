class Rental < ApplicationRecord
	belongs_to :lesson
	belongs_to :student
	belongs_to :resource

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

def resource_type_text
	case resource_type
	when 'ski'
		return 'Skis'
	when 'snowboard'
		return 'Snowboard'
	when 'ski_boot'
		return 'Ski Boots'
	when 'snowboard_boot'
		return 'Snowboard Boots'
	else
	end
end

end
