class Rental < ApplicationRecord
	belongs_to :lesson
	belongs_to :student
	belongs_to :resource
	validates :student_id, presence: true

def self.create_sample_students_for_empty_rentals
	rentals_to_fix = []
	Rental.all.each do |rental|
		if rental.student.nil?
			rentals_to_fix << rental
		end
	end
	rentals_to_fix.each do |rental|
		Student.find_or_create_by!({
			lesson_id: rental.lesson.id,
			name: 'TBD',
			age_range: '99',
			gender: 'Male',
			most_recent_level: 'Level 1 - first-time ever, no previous experience.',
			relationship_to_requester: 'I am a sample student',
			needs_rental: true
		})
		rental.student_id = Student.last.id
		rental.save!
	end
end

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

def self.match_resource_type_to_activity
	Rental.all.each do |rental|
		next if rental.lesson.nil?
		if rental.lesson.activity == "Snowboard" && rental.resource_type == "ski"
			puts "!!! found mismatching entry for snowboard rental -- skis instead of board"
			rental.resource_type = "snowboard"
			rental.save!
		elsif 
			rental.lesson.activity == "Snowboard" && rental.resource_type == "ski_boot"
			puts "!!! found mismatching entry for snowboard rental -- ski boots instead of board boots"
			rental.resource_type = "snowboard_boot"
			rental.save!
		end
	end
end

end
