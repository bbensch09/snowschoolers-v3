class Section < ApplicationRecord
	has_many :lessons
	belongs_to :sport
	belongs_to :instructor

	# def name
	# 	return "#{self.age_group} #{self.lesson_type} - #{self.sport.activity_name}"
	# end

	def instructor_name_for_section
		if self.instructor_id
			return self.instructor.name
		else
			return "Not yet assigned"
		end
	end

	def self.seed_default_sections(date = Date.today)
		Section.create!({
			date: date,
			name: 'Snow Rangers - Ski',
			lesson_type: 'Group Lesson',
			age_group: 'Kids',
			sport_id: 1,
			level: 'Level 1 - first-timer',
			capacity: 5,
			instructor_id: nil
			})
		Section.create!({
			date: date,
			name: 'Snow Rangers - Snowboard',
			lesson_type: 'Group Lesson',
			age_group: 'Kids',
			sport_id: 1,
			level: 'Level 1 - first-timer',
			capacity: 5,
			instructor_id: nil
			})
		Section.create!({
			date: date,
			name: 'Mountain Rangers - Ski',
			lesson_type: 'Group Lesson',
			age_group: 'Kids',
			sport_id: 1,
			level: 'Level 1 - first-timer',
			capacity: 8,
			instructor_id: nil
			})
		Section.create!({
			date: date,
			name: 'Mountain Rangers - Snowboard',
			lesson_type: 'Group Lesson',
			age_group: 'Kids',
			sport_id: 1,
			level: 'Level 1 - first-timer',
			capacity: 8,
			instructor_id: nil
			})	
		Section.create!({
			date: date,
			name: 'Adult Groups - AM Ski',
			lesson_type: 'Group Lesson',
			age_group: 'Adults',
			sport_id: 1,
			level: 'Level 1 - first-timer',
			capacity: 10,
			instructor_id: nil
			})	
		Section.create!({
			date: date,
			name: 'Adult Groups - AM Snowboard',
			lesson_type: 'Group Lesson',
			age_group: 'Adults',
			sport_id: 1,
			level: 'Level 1 - first-timer',
			capacity: 10,
			instructor_id: nil
			})
		Section.create!({
			date: date,
			name: 'Adult Groups - PM Ski',
			lesson_type: 'Group Lesson',
			age_group: 'Adults',
			sport_id: 1,
			level: 'Level 1 - first-timer',
			capacity: 10,
			instructor_id: nil
			})	
		Section.create!({
			date: date,
			name: 'Adult Groups - PM Snowboard',
			lesson_type: 'Group Lesson',
			age_group: 'Adults',
			sport_id: 1,
			level: 'Level 1 - first-timer',
			capacity: 10,
			instructor_id: nil
			})
		Section.create!({
			date: date,
			name: 'Private - Ski',
			lesson_type: 'Private Lesson',
			age_group: 'Adults',
			sport_id: 1,
			level: 'Level 1 - first-timer',
			capacity: 1,
			instructor_id: nil
			})
		Section.create!({
			date: date,
			name: 'Private - Snowboard',
			lesson_type: 'Private Lesson',
			age_group: 'Adults',
			sport_id: 1,
			level: 'Level 1 - first-timer',
			capacity: 1,
			instructor_id: nil
			})									

	end

	def student_count
		Lesson.where(section_id:self.id).count
	end

	def remaining_capacity
		self.capacity - self.student_count
	end

end
