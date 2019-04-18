class CalendarBlock < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :lesson_time
  before_save :set_prime_day
  # validates :lesson_time, presence: true
		#eligible state values:
		#[Available, Not Available, Booked]

	def start_time
		self.date
	end

	def lesson
		Lesson.where(instructor_id:self.instructor_id,lesson_time_id:self.lesson_time_id).first
	end

	def set_prime_day
		if HW_HOLIDAYS.include?(self.date.to_s)
			self.prime_day = true
		else
			self.prime_day = false
		end
		return true
	end

	def self.open_all_days(instructor_id)		
		dates = self.remaining_dates_in_season
		dates.each do |date|			
			c = CalendarBlock.find_or_create_by!({
				date: date,
				instructor_id: instructor_id,
				})
			unless c.state == 'Booked'
			c.state = 'Available'
			c.save
			end
		end	
	end

	def self.open_all_weekends(instructor_id)		
		dates = self.remaining_dates_in_season
		dates.each do |date|
			if date.wday == 0 || date.wday == 6
				c = CalendarBlock.find_or_create_by!({
				date: date,
				instructor_id: instructor_id,
				})
				unless c.state == 'Booked' 
				c.state = 'Available'
				c.save
				end
			end
		end	
	end

	def self.block_all_days(instructor_id)		
		dates = self.remaining_dates_in_season
		dates.each do |date|
			c = CalendarBlock.find_or_create_by!({
				date: date,
				instructor_id: instructor_id,
				})
			unless c.state == 'Booked'
			c.state = 'Not Available'
			c.save
			end
		end	
	end

	def toggle_display
		if self.state == "Available"
			return "Mark as Not Available"
		elsif self.state == "Not Available"
			return "Mark as Available"
		else
			return self.state	
		end		
	end

	def availability_formatting
		if self.state == "Available"
			value = 'availability-open'
		elsif self.state == "Not Available"
			value = 'availability-blocked'
		elsif self.state == "Booked"
			value = 'availability-booked'
		end		
		return value
	end

	def toggle_availability
		if self.state == "Available"
			self.state = "Not Available"
			self.save
		elsif self.state == "Not Available"
			self.state = "Available"
			self.save
		end
		self.state
	end

	def self.instructors_available(date)
		CalendarBlock.where(state:'Available',date:date)
	end

	def self.remaining_dates_in_season
		dates = []
		date = Date.today
		while date.to_s <= '2019-04-21'
			dates << date
			date = date +1
		end
		return dates
	end


end
