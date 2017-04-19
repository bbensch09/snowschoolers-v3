class Shift < ApplicationRecord
	  belongs_to :instructor
	  has_one :section

  def self.create_instructor_shifts(date)
  	Instructor.all.to_a.each do |instructor|
  		Shift.create!({
  			start_time: "#{date.to_s} 08:00:00",
  			end_time: "#{date.to_s} 16:00:00",
  			name: ['Snow Rangers - Ski', 'Snow Rangers - Snowboard','Mountain Rangers - Ski', 'Mountain Rangers - Snowboard','Adult Groups - Ski','Adult Groups - Snowboard','Private - Ski','Private - Snowboard'].sample,
  			status: ['TBD','Scheduled','Scheduled','Scheduled','Unavailable'].sample,
  			instructor_id: instructor.id
  			})
  	end
  end

  def self.parametized_date(date)
    return [date.strftime('%m'),date.strftime('%d'),date.year].join('%2F') 
    # "#{date.strftime("%m")}%2F#{date.strftime("%d")}%2F#{date.strftime("%Y")}"
    # "04%2F13%2F2017"
  end

  def self.capacity_status_color(date)
  	case 
  		when self.capacity(date) > 75
  			return "red-shift"
  		when self.capacity(date) > 50
  			return "yellow-shift"
  		else
  			return "green-shift"
	end

  end

  def self.capacity(date)
  	total_students = Lesson.bookings_for_date(date)
  	scheduled_instructors = Shift.all.to_a.keep_if { |shift| shift.start_time.to_date == date && shift.status == "Scheduled"}
  	# return scheduled_instructors.count
  	avg_capcity_per_instructor = 6
  	total_capacity = avg_capcity_per_instructor * scheduled_instructors.count
  	capacity_utilization = (total_students.to_f / total_capacity.to_f) *100
  end

  def shift_status_color
  	case self.status
  	when 'TBD'
  		return 'yellow-shift'
  	when 'Scheduled'
  		return 'blue-shift'
  	when 'Unavailable'
  		return 'red-shift'
  	when 'Completed'
  		return 'green-shift'
	when 'Assigned'
		return 'green-shift'
  	end
  end

end
