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
  validate :participant_exists, on: :update

  # old -- used to confirm participants are all over the age of 8 (for group lessons)
  # validate :age_validator, on: :update
  validate :check_session_capacity
  before_save :check_session_capacity
  before_save :confirm_valid_promo_code

  def check_for_duplicates
    students = self.participants.sort_by(&:name)
    duplicates = false
    previous_name = ""
    previous_age_range = ""
    students.each do |s|
      if s.name == previous_name && s.age_range == previous_age_range
        duplicates = true
      else
        previous_name = s.name
        previous_age_range = s.age_range
      end
    end
    @duplicates = duplicates
  end  


  def send_waiver_link_to_customers_phone
    return if ENV['twilio_status'] == "inactive"
    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_AUTH']
    snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
    recipient = self.phone_number
    body = "Thanks for visiting us! In order to complete your reservation, please click below to sign your waiver. https://waiver.smartwaiver.com/v/snowschoolers2021"
    @client = Twilio::REST::Client.new account_sid, auth_token
          @client.api.account.messages.create({
          :to => recipient,
          :from => "#{snow_schoolers_twilio_number}",
          :body => body
      })
    LessonMailer.notify_admin_sms_logs_sledding(self,recipient,body).deliver!
  end

  def retail_item_price_per_item
    return self.retail_item_price unless self.retail_item_price.nil?
    case self.retail_item_name
      when 'Snow shoe tour'
        then 50.00
      when 'Neck gaitor mask'
        then 20.00
      when 'Gloves'
        then 20.00
      when 'Hand warmers'
        then 3.00
      else 0.00
      end
  end

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

  def self.assign_session_to_tix_without_session_details
    unassigned_tickets = Ticket.all.select{|ticket| ticket.slot.blank?}
    # puts "!!!!!! there were #{unassigned_tickets.count} tix found without sessions."
    unassigned_tickets.each do |ticket|
      ticket.lesson_time = lesson_time = LessonTime.find_or_create_by(date:ticket.date.to_s,slot:"Morning (9:30am-1pm)")
      lesson_time.save!
      ticket.save!
      puts "!!!!!! the booking with ID #{ticket.id} was blank and has been assigned to the mnorning."
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
    if !self.num_days.nil?
      custom="-MultiDay-"+num_days.to_s
    else
      custom=""
    end
    if !self.sleds_purchased.nil?
      sled_count = "#" + self.sleds_purchased.to_s
    else
      sled_count = ""
    end
  	ticket_count = self.participants.count.to_s
  	id = self.id.to_s.rjust(4,"0")
  	confirmation_number = l+'-'+id+'-'+date+'-'+ticket_count+custom+sled_count
  end

  def self.mark_all_confirmed
  	Ticket.all.to_a.each do |ticket|
  		ticket.state = 'confirmed'
  		ticket.save!
  	end
  end

  def self.update_payment_method_and_booking_order_value_for_all_sledding_bookings
    bookings = Ticket.all.select{|ticket| ticket.state == "booked"}
    bookings.each do |booking|
      if booking.booking_order_value.nil?
        booking.booking_order_value = booking.price
        puts "!!! preparing to update Ticket ID#{booking.id} with a booking order value of #{booking.price}.!!!"
        booking.save
      end
      if booking.payment_method.nil?
        booking.payment_method = "stripe"
        puts "!!! preparing to update Ticket ID#{booking.id} with payment method = stripe.!!!!"
        booking.save
      end
    end
    return "!!!Successfully updated all bookings!!!"
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
	return true if active_states.include?(state)
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

def self.bookings_this_season
  bookings = Ticket.where(state:'booked').to_a
  bookings = bookings.keep_if{|ticket| ticket.this_season?}
end 

def self.total_tickets_sold_this_season
  bookings = Ticket.bookings_this_season
  tickets = 0
  bookings.each do |booking|
    ticket_count = booking.participants.count
    tickets += ticket_count
  end
  return tickets
end

def self.total_ticket_revenue_this_season
	bookings = Ticket.bookings_this_season
	total = 0
	bookings.each do |ticket|
		total += ticket.price.to_i
	end
	return total
end

def self.todays_bookings
  tickets = Ticket.where(state:'booked').to_a
  tickets = tickets.keep_if{|ticket| ticket.date == Date.today()}
end

def self.todays_ticket_count
  tickets = self.todays_bookings
  ticket_count = 0
  tickets.each do |ticket|
    ticket_count += ticket.participants.count
  end
  return ticket_count
end

def self.todays_ticket_revenue
  tickets = Ticket.todays_bookings
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

def participants_3_and_under
  count = 0
  self.participants.each do |participant|
    if participant.age_range.to_i <= 3
      count +=1
    end
  end
  return count
end

def total_participants
  self.participant.count
end

def price
	calendar_period = self.lookup_calendar_period(self.lesson_time.date,self.location.id)
      # puts "!!!!lookup calendar period status, it is: #{calendar_period}"
      # product = Product.where(location_id:25,calendar_period:calendar_period).first
  if self.product.nil?
      return "Product price or product not found" #99 #default lesson price - temporary
  elsif self.booking_order_value && !self.additional_info.blank?
  	price = self.booking_order_value
  else
  	price = product.price * [1,(self.participants.count - self.participants_3_and_under)].max
  end

  # price of additional retail items & promotions
  price_extras = 0
  if self.sleds_purchased && self.sleds_purchased >=1
    price_extras += sleds_purchased*20
    # puts "!!!!the subtotal of sleds is #{price_extras}}"
  end
  if self.free_participants_redeemed && self.free_participants_redeemed >=1
    price_extras -= free_participants_redeemed*self.product.price
    # puts "!!!!the subtotal of sleds minus free participants is #{price_extras}}"  
  end
  if self.retail_item_name && self.retail_item_name !=""
    retail_price = self.retail_item_quantity * retail_item_price_per_item
    price_extras += retail_price
    # puts "!!!!the subtotal of retail itmes is  #{retail_price}}"
  end
  # puts "!!!!the subtotal of sleds, promo tickets, and retails items is #{price_extras}}"
  price = price + price_extras
  # puts "!!!! the raw price is #{price}"

  if self.promo_code
  	case self.promo_code.discount_type
  	when 'cash'
        puts "!!!discount of #{self.promo_code.discount} is applied to total price."
        price = (price.to_f - self.promo_code.discount.to_f)
    when 'percent'
        puts "!!!discount percentage of #{self.promo_code.discount} is applied to total price."
        price = (price.to_f * (1-self.promo_code.discount.to_f/100))
    end
end
return price.to_s
end

def price_without_promo
  calendar_period = self.lookup_calendar_period(self.lesson_time.date,self.location.id)
      # puts "!!!!lookup calendar period status, it is: #{calendar_period}"
      # product = Product.where(location_id:25,calendar_period:calendar_period).first
  if self.product.nil?
      return "Product price or product not found" #99 #default lesson price - temporary
  elsif self.booking_order_value && !self.additional_info.blank?
    price = self.booking_order_value
  else
    price = product.price * [1,(self.participants.count - self.participants_3_and_under)].max
  end

  # price of additional retail items & promotions
  price_extras = 0
  if self.sleds_purchased && self.sleds_purchased >=1
    price_extras += sleds_purchased*20
    # puts "!!!!the subtotal of sleds is #{price_extras}}"
  end
  if self.free_participants_redeemed && self.free_participants_redeemed >=1
    price_extras -= free_participants_redeemed*self.product.price
    # puts "!!!!the subtotal of sleds minus free participants is #{price_extras}}"  
  end
  if self.retail_item_name && self.retail_item_name !=""
    retail_price = self.retail_item_quantity * retail_item_price_per_item
    price_extras += retail_price
    # puts "!!!!the subtotal of retail itmes is  #{retail_price}}"
  end
  # puts "!!!!the subtotal of sleds, promo tickets, and retails items is #{price_extras}}"
  price = price + price_extras
  # puts "!!!! the raw price is #{price}"  
return price.to_s
end

def retail_items_purchased?
  return false if self.retail_item_name == "" || self.retail_item_name.nil?
  return false if self.retail_item_quantity == "" || self.retail_item_quantity.nil?
  return true
end

def price_per_student
	return (self.price.to_f) / (self.participants.count)
end

def self.to_csv(options = {})
	desired_columns = %w{ id requester_name created_at date product_name slot total_participants sleds_purchased price payment_method state location
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

def current_session_bookings
  same_session_entries = Ticket.where(lesson_time_id:self.lesson_time_id).to_a
  puts "!!! there are #{same_session_entries.count} bookings found in same_session_entries"
  same_session_paid_bookings = same_session_entries.keep_if{|t| t.booked?}
  return same_session_paid_bookings
end

def current_session_tickets_sold
	same_session_paid_bookings = self.current_session_bookings
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
