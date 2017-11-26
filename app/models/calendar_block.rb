class CalendarBlock < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :lesson_time
  # validates :lesson_time, presence: true

	def start_time
		self.date
	end

	def self.open_all_days(instructor_id)		
		dates = self.remaining_dates_in_season
		dates.each do |date|
			c = CalendarBlock.find_or_create_by!({
				date: date,
				instructor_id: instructor_id,
				})
			c.state = 'Available'
			c.save!
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
				c.state = 'Available'
				c.save!
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
			c.state = 'Not Available'
			c.save!
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
		end		
		return value
	end

	def toggle_availability
		if self.state == "Available"
			self.state = "Not Available"
		elsif self.state == "Not Available"
			self.state = "Available"	
		end		
	end

	def self.remaining_dates_in_season
		dates = []
		date = Date.today
		while date.to_s < '2018-04-15'
			dates << date
			date = date +1
		end
		dates
	end


end
