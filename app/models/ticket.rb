class Ticket < ApplicationRecord
	belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'
	belongs_to :lesson_time
	has_many :participants
	has_one :review
	belongs_to :promo_code
	has_many :transactions
  belongs_to :product #, class_name: 'Product', foreign_key: 'product_id'
  belongs_to :section
  accepts_nested_attributes_for :participants, reject_if: :all_blank, allow_destroy: true

  validates :requested_location, presence: true
  validates :phone_number, presence: true, on: :update
  validates :terms_accepted, inclusion: { in: [true], message: 'must accept terms' }, on: :update
  # validate :participant_exists, on: :update

  # old -- used to confirm participants are all over the age of 8 (for group lessons)
  # validate :age_validator, on: :update
  # validate :check_session_capacity
  # before_save :check_session_capacity
  before_save :confirm_valid_promo_code


  def is_sample_booking?
  	return false if self.requester_name.nil?
  	return true if self.requester_name.include?("John Doe")
  end

  def participants_under_age_18
    kids = self.participants.to_a.keep_if{|participant| participant.age_range.to_i < 18}
    kids_names = []
    kids.each do |participant|
      kids_names << participant.name
    end
    kids_names.join(', ')
  end

  def self.set_dates_for_sample_bookings
  	today = LessonTime.find_or_create_by(date:Date.today)
  	tomorrow = LessonTime.find_or_create_by(date:Date.tomorrow)
  	sample_bookings = Ticket.all.to_a.keep_if{|booking|booking.is_sample_booking?}
  	sample_bookings.each do |booking|
  		if booking.id.even?
  			booking.lesson_time_id = today.id
  			puts "!!! set sample booking date to today"
  		else
  			booking.lesson_time_id = tomorrow.id
  			puts "!!! set sample booking date to tomorrow"
  		end
  		booking.save!
  	end
  end

  def self.remove_all_but_two_sample_bookings
  	sample_bookings = Ticket.all.to_a.keep_if{|booking|booking.is_sample_booking?}
  	sample_bookings[0..-2].each do |booking|
  		booking.destroy!
  	end
  end

  def confirmation_number
  	date = self.lesson_time.date.to_s.gsub("-","")
  	date = date[4..-1]
  	case self.location.name
  	when 'Kingvale'
  		l = 'SLED'
  	else
  		l = 'XX'
  	end
  	ticket_count = self.participants.count.to_s
  	id = self.id.to_s.rjust(4,"0")
  	confirmation_number = l+'-'+id+'-'+date+'-'+ticket_count
  end

  def self.mark_all_confirmed
  	Ticket.all.to_a.each do |ticket|
  		ticket.state = 'confirmed'
  		ticket.save!
  	end
  end  

  def email
  	if self.requester
  		return self.requester.email
  	elsif self.guest_email
  		return self.guest_email
  	else
  		"N/A"
  	end
  end

  def name
  	if self.requester_name
  		return self.requester_name
  	elsif self.guest_email
  		return self.guest_email
  	else
  		"N/A"
  	end
  end

  def self.bookings_for_date(date)
  	tickets = Ticket.all.to_a.keep_if{|ticket| ticket.date == date}
  	return tickets.count
  end

  def date
  	lesson_time.date
  end

  def slot
  	lesson_time.slot
  end

  def product
  		Product.where(location_id:self.location.id,product_type:"sledding_ticket",calendar_period:self.lookup_calendar_period(self.lesson_time.date,25)).first        
  end

  def final_charge
  	self.transactions.last.final_amount - self.price.to_i
  end

  def location
  	Location.find(self.requested_location.to_i)
  end

  def active?
  	active_states = ['new', 'booked', 'confirmed','gift_voucher_reserved']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    active_states.include?(state)
end

def active_today?
	active_states = ['confirmed','ready_to_book']
    #removed 'confirmed' from active states to avoid sending duplicate SMS messages.
    return true if self.date == Date.today && active_states.include?(state)
end

def paid?
	active_states = ['booked','confirmed',]
	return true if active_states.include?(state) && self.date > Date.today
end

def upcoming?
	active_states = ['new','booked','confirmed','finalizing','ready_to_book']
	return true if active_states.include?(state) && self.date > Date.today
end

def is_gift_voucher?
	if self.is_gift_voucher == true
		return true
	else
		return false
	end
end

def new?
	state == 'new'
end

def canceled?
	state == 'canceled'
end

def booked?
	state == 'booked'
end

def ready_to_book?
	state == 'ready_to_book'
end

def ready_for_deposit?
 self.state == "ready_to_book" || self.deposit_status.nil? || self.deposit_status == 'pending_new_payment'
end

def referral_source
	case self.how_did_you_hear.to_i
	when 1
		return 'From a friend'
	when 2
		return 'Facebook'
	when 3
		return 'Google'
	when 4
		return 'From a postcard'
	when 5
		return 'From someone at Homewood'
	when 6
		return 'Tahoe Daves'
	when 7
		return 'Ski Butlers'
	when 8
		return 'Yelp'
	when 100
		return 'Other'
	end
end

def lookup_calendar_period(date,location_id)
	date = date.to_s
	if KV_HOLIDAYS.include?(date)
		return 'Holiday'
	else
		return 'Regular'
	end
end

def this_season?
	self.lesson_time.date.to_s >= '2020-11-01'
end

def last_season?
	self.lesson_time.date.to_s <= '2020-04-30' && self.lesson_time.date.to_s >= '2019-12-01'
end  

def self.total_tickets_this_season
	tickets = Ticket.where(state:'booked').to_a
	tickets = tickets.keep_if{|ticket| ticket.this_season?}
end

def self.total_ticket_revenue_this_season
	tickets = Ticket.total_tickets_this_season
	total = 0
	tickets.each do |ticket|
		total += ticket.price.to_i
	end
	return total
end

def self.todays_tickets
  tickets = Ticket.where(state:'booked').to_a
  tickets = tickets.keep_if{|ticket| ticket.date == Date.today()}
end

def self.todays_ticket_revenue
  tickets = Ticket.todays_tickets
  revenue = 0
  tickets.each do |ticket|
    revenue += ticket.price.to_i
  end
  return revenue
end

def participants_2_and_under
	count = 0
	self.participants.each do |participant|
		if participant.age_range.to_i <= 2
			count +=1
		end
	end
	return count
end

def price
	calendar_period = self.lookup_calendar_period(self.lesson_time.date,self.location.id)
      # puts "!!!!lookup calendar period status, it is: #{calendar_period}"
      # product = Product.where(location_id:25,calendar_period:calendar_period).first
  if self.product.nil?
      return "Product price or product not found" #99 #default lesson price - temporary
  elsif self.booking_order_value
  	price = self.booking_order_value
  else
  	price = product.price * [1,(self.participants.count - self.participants_2_and_under)].max
  end
  if self.promo_code
  	case self.promo_code.discount_type
  	when 'cash'
        # puts "!!!discount of #{self.promo_code.discount} is applied to total price."
        price = (price.to_f - self.promo_code.discount.to_f)
    when 'percent'
        # puts "!!!discount percentage of of #{self.promo_code.discount} is applied to total price."
        price = (price.to_f * (1-self.promo_code.discount.to_f/100))
    end
end
return price.to_s
end

def price_per_student
	return (self.price.to_f) / (self.participants.count)
end

def self.to_csv(options = {})
	desired_columns = %w{
		id date created_at confirmation_number requester_name phone_number guest_email price
	}
	CSV.generate(headers: true) do |csv|
		csv << desired_columns
		all.each do |ticket|
			csv << ticket.attributes.values_at(*desired_columns)
		end
	end
end

def check_session_capacity
  return true if self.skip_validations == true
  if session_capacity_remaining - self.participants.count > 0
		puts "!!! the current remaining sledding tickets is #{self.session_capacity_remaining}"
		return true
	else
		errors.add(:ticket,"Unfortunately this sledding session is sold out. Please try another time slot. To see which sessions still have capacity, visit tickets.granlibakken.com/sledding/calendar.")
		return false
	end

end

def current_session_tickets_sold
	same_session_entries = Ticket.where(lesson_time_id:self.lesson_time_id).to_a
  puts "!!! there are #{same_session_entries.count} bookings found in same_session_entries"
	same_session_paid_bookings = same_session_entries.keep_if{|t| t.booked?}
	tickets = 0
	same_session_paid_bookings.each do |booking|
		tickets+= booking.participants.count
    puts "!!! added #{booking.participants.count} tickets to running total"
	end
	puts "!!! There are #{same_session_paid_bookings.count} other bookings already and #{tickets} already booked.}"
	return tickets
end

def session_capacity_remaining
	return SLEDHILL_CAPACITY - current_session_tickets_sold
end  

private

def participant_exists
	puts "!!!!!checking if at least one participant exists"
	errors.add(:participants, "count must be greater than zero") unless participants.any?
end

def confirm_valid_promo_code
	puts "!!! checking for promo code"
	return true if self.promo_code.nil?
	promo_redemptions_count = Lesson.where(promo_code_id:self.promo_code_id,state:'confirmed').count
	if promo_redemptions_count > 0 && self.promo_code.single_use == true
		errors.add(:lesson, "ERROR: Unfortunately your promo code has already been redeemed.")
		return false
    # weekday redemptions
elsif self.promo_code.description == 'groupon 2-ticket weekday redemption' && (self.num_days !=2 || self.date.wday >4)
	errors.add(:lesson, "ERROR: Your promo code is valid for 2 participants on Mon-Thurs. Please be sure to enter 2 student names and select an appropriate date. If you've reached this error already, please close this window and reopen your unique URL in a new tab.")
	return false
elsif self.promo_code.description == 'groupon 4-ticket weekday redemption' && (self.num_days != 4 || self.date.wday >4)
	errors.add(:lesson, "ERROR: Your promo code is valid for 4 participants on Mon-Thurs. Please be sure to enter 2 student names and select an appropriate date. If you've reached this error already, please close this window and reopen your unique URL in a new tab.")
	return false
    # weekend redemptions
elsif self.promo_code.description == 'groupon 2-ticket weekend redemption' && (self.num_days !=2  || self.date.wday <=4)
	errors.add(:lesson, "ERROR: Your promo code is valid for 2 participants on weekends only (Fri-Sun). Please be sure to enter 2 student names and select an appropriate date. If you've reached this error already, please close this window and reopen your unique URL in a new tab.")
	return false
elsif self.promo_code.description == 'groupon 4-ticket weekend redemption' && (self.num_days != 4  || self.date.wday <=4)
	errors.add(:lesson, "ERROR: Your promo code is valid for 4 participants on weekends only (Fri-Sun). Please be sure to enter 2 student names and select an appropriate date. If you've reached this error already, please close this window and reopen your unique URL in a new tab.")
	return false
else
	return true
end
end


end
