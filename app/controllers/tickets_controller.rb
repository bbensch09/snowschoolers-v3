class TicketsController < ApplicationController
  respond_to :html
  skip_before_action :authenticate_user!, only: [:index, :new, :create, :complete, :complete_sledding_ticket, :confirm_reservation, :update, :edit, :show, :liability_release_agreement, :create_walk_in_sledding_ticket]
  skip_before_action :verify_authenticity_token, only: [:confirm_reservation, :create, :update]  
  # low friction hackey solution -- don't require authentication for most customer-facing pages; removed temporarily May 2019
  before_action :set_ticket, only: [:show, :duplicate, :complete, :complete_sledding_ticket, :update, :edit, :edit_wages, :destroy, :reissue_invoice, :issue_refund, :confirm_reservation, :admin_reconfirm_state, :mark_lesson_complete,  :authenticate_from_cookie, :send_day_before_reminder_email, :admin_confirm_deposit, :admin_confirm_airbnb, :admin_confirm_booked_with_modification, :enable_email_notifications, :disable_email_notifications, :enable_sms_notifications, :disable_sms_notifications, :send_review_reminders_to_student, :liability_release_agreement, :admin_confirm_cash, :admin_confirm_square, :admin_confirm_split_charge, :reminder_sledding_confirmation]
  before_action :set_admin_skip_validations


  def liability_release_agreement
    @participants = @ticket.participants
    render 'liability_release_agreement', layout: 'rental_agreement_layout'
  end

  def set_admin_skip_validations
    if current_user && (current_user.email == 'brian@snowschoolers.com' || current_user.user_type == 'Snow Schoolers Employee')
      session[:skip_validations] = true
      if @ticket
        @ticket.skip_validations = true
      else
      # puts "no ticket found yet"
      end
    end
  end

  def reminder_sledding_confirmation
    puts "!!!!sending reminder email for tickets, often after CS change"
    LessonMailer.reminder_sledding_confirmation(@ticket).deliver!
    redirect_to @ticket
    flash[:notice] = "Success! Reminder email has been sent to the customer."
  end    

  # GET /tickets
  # GET /tickets.json
  def index
    @tickets_to_export = Ticket.where(state:"confirmed")
    # could modify this manually if we want a full export of all bookings to be loaded in the browser
    @tickets = Ticket.last(200).to_a.keep_if{|ticket| ticket.lesson_time && ticket.booked? || ticket.ready_to_book?}
    @tickets = @tickets.sort! { |a,b| b.lesson_time.date <=> a.lesson_time.date }
    @show_search_options = true
    respond_to do |format|
          format.html {render 'index'}
          format.csv { send_data @tickets_to_export.to_csv, filename: "sledding-emails-export-#{Date.today}.csv" }
    end
  end

  def search
    @tickets = Ticket.select{|ticket| ticket.deposit_status == 'confirmed' && ticket.this_season? }
    # @tickets = @tickets.sort! { |a,b| a.created_at <=> b.created_at }
    # @tickets = @tickets.first(100)
    respond_to do |format|
          format.html {render 'search_results'}
          format.csv { send_data Ticket.all.to_csv, filename: "sledding-tickets-export-#{Date.today}.csv" }
        end
  end


  # GET /tickets/1
  # GET /tickets/1.json
  def show
    if @ticket.state == "ready_to_book"
      GoogleAnalyticsApi.new.event('ticket-requests', 'ready-for-deposit')
    end
    @lesson_time = @ticket.lesson_time
    check_user_permissions
  end

  # GET /tickets/new
  def new
    @ticket = Ticket.new
  end

  # GET /tickets/1/edit
  def edit
    redirect_to complete_sledding_ticket_path(@ticket)
  end

  # POST /tickets
  # POST /tickets.json
  def create
    @ticket = Ticket.new(ticket_params)
    @ticket.lesson_time = @lesson_time = LessonTime.find_or_create_by(lesson_time_params)
    @slot = @lesson_time.slot
    @ticket.requested_location = 25
    if current_user && (current_user.email == 'brian@snowschoolers.com' || current_user.user_type == 'Snow Schoolers Employee')
      puts "!!!current user is admin, preparing to set skip_validations boolean to true."
      session[:skip_validations] = true
      @ticket.agent_id = current_user.id
      @ticket.skip_validations = true
    end

    if @ticket.save
        redirect_to complete_sledding_ticket_path(@ticket)
        flash[:notice] = "Almost there! We just need a few more details."
    else
        flash[:alert] = "Unfortunately that sledding session is already at capacity. Please pick another time."
        render 'new'
    end
  end

  def create_walk_in_sledding_ticket
    walk_in_ticket_params = {
      date:LessonTime.next_available_date,
      slot:LessonTime.next_available_slot,
    }
    @ticket = Ticket.new
    @ticket.lesson_time = @ticket_time = LessonTime.find_or_create_by(walk_in_ticket_params)
    @slot = @ticket_time.slot
    @ticket.requested_location = 25
    if @ticket.save
        redirect_to complete_sledding_ticket_path(@ticket)
        flash[:notice] = "Almost there! We just need a few more details."
    else
        flash[:alert] = "Unfortunately that sledding session is already at capacity. Please pick another time."
        render 'new'
    end
  end

  def create_sled_only_sale
    walk_in_ticket_params = {
      date:LessonTime.next_available_date,
      slot:LessonTime.next_available_slot,
    }
    @ticket = Ticket.new
    @ticket.lesson_time = @ticket_time = LessonTime.find_or_create_by(walk_in_ticket_params)
    @ticket.additional_info = "This ticket represents a retail only sale (e.g. sleds) and is not attached to any guests specifically."
    @ticket.activity = "retail"
    @slot = @ticket_time.slot
    @ticket.requested_location = 25
    @ticket.phone_number = "530-430-7669"
    @ticket.terms_accepted = true
    if @ticket.save
        render 'complete_retail_purchase'
        flash[:notice] = "Almost there! We just need a few more details."
    else
        flash[:alert] = "Unfortunately that sledding session is already at capacity. Please pick another time."
        render 'new'
    end
  end

  def complete_retail_purchase
  end

  def complete
    @lesson_time = @ticket.lesson_time
    @slot = @ticket.slot
    @promo_code = PromoCode.new
    GoogleAnalyticsApi.new.event('ticket-requests', 'load-full-form')
    flash.now[:notice] = "You're almost there! We just need a few more details."
    flash[:complete_form] = 'TRUE'
    cookies[:lesson] = {
      value: User.last.id + 30,
      expires: 1.year.from_now
    }
    render 'full_form'
  end

  # PATCH/PUT /tickets/1
  # PATCH/PUT /tickets/1.json
  def update
    @original_ticket = @ticket.dup
    @ticket.assign_attributes(ticket_params)
    @ticket.lesson_time = @lesson_time = LessonTime.find_or_create_by(lesson_time_params)
    unless current_user && current_user.user_type == "Snow Schoolers Employee"
      @ticket.requester = current_user
    end
    if @ticket.guest_email
      if User.find_by_email(@ticket.guest_email.downcase)
          @ticket.requester_id = User.find_by_email(@ticket.guest_email.downcase).id
          puts "!!!! lesson guest email exists; found matching email from previous entry"
      else
          User.create!({
          email: @ticket.guest_email,
          password: 'snowschoolers',
          user_type: "Student",
          name: "#{@ticket.guest_email}"
          })
         @ticket.requester_id = User.last.id
      puts "!!!! user is checking out as guest; create a temp email for them that must be confirmed"
      end
    end
    
    if @ticket.is_gift_voucher? && current_user.user_type == "Snow Schoolers Employee" && @ticket.requester_id.nil?
      @user = User.new({
          email: @ticket.gift_recipient_email,
          password: 'snowschoolers',
          user_type: "Student",
          name: "#{@ticket.gift_recipient_name}"
        })
      @user.skip_confirmation!
      @user.save!
      @ticket.requester_id = User.last.id
      puts "!!!! admin is creating a new user to receive a gift voucher; new user need not be confirmed"
    end
    
    if current_user && @ticket.is_gift_voucher? && current_user.email == @ticket.gift_recipient_email.downcase
      @ticket.state = 'booked'
      puts "!!!! marking voucher as booked & sending SMS to instructors"
    end

    if current_user && current_user.user_type == "Snow Schoolers Employee"
      @ticket.agent_id = current_user.id
    end

    unless @ticket.deposit_status == 'confirmed'
      @ticket.state = 'ready_to_book'
    end

    if @ticket.promo_code && @ticket.promo_code.promo_code == "AIRBNBX"
      @ticket.state = "booked"
      @ticket.deposit_status = "paid through Airbnb"
      if @ticket.package_info.nil? 
        @ticket.package_info = "this lesson was updated with the promo_code AIRBNBX and has $0 balance"
      else
        @ticket.package_info += "this lesson was updated with the promo_code AIRBNBX and has $0 balance"
      end
      @ticket.save!
    end

    puts "!!!! prepare to save ticket reservation"
    if @ticket.check_session_capacity
      puts "!!!confirmed there is capacity remaining and this ticket can proceed to payment. if full, rediect back."
    else
      flash[:alert] = "Unfortunately that sledding session is already at capacity. Please pick another time."
    end

    puts "!!!! check if ticket status is open"
    if @ticket.check_open_status
      puts "!!!confirmed that hill is open and can proceed to payment. if not, redirect back."
      flash[:notice] = 'Almost there! Please enter your payment info to complete your reservation.'              
    else
      flash[:alert] = "Unfortunately that sledhill will not open on your selected date. To confirm when we will be open, please call 530-430-SNOW or email us at hello@snowschoolers.com"
    end

    if @ticket.save
      GoogleAnalyticsApi.new.event('ticket-requests', 'full_form-updated', params[:ga_client_id])
      @user_email = current_user ? current_user.email : "unknown"
      cookies[:ticket_reservation_id] = {
      value: @ticket.id,
      expires: 1.year.from_now
      }
      session[:ticket_reservation_id] = @ticket.id
      if @ticket.state == "ready_to_book"
        LessonMailer.notify_admin_sledding_full_form_updated(@ticket.id).deliver
      end
      unless (current_user && current_user.user_type == "Snow Schoolers Employee")
        @ticket.send_waiver_link_to_customers_phone
      end
      puts "!!!! Ticket update saved; update notices sent"
      redirect_to "/tickets/#{@ticket.id}?state=#{@ticket.state}"
    else
      @ticket.state = "saved, not ready to book"
      puts "!!!!!Ticket NOT saved, need to DEBUG WHY NOT -- 11.22.20"
      # redirect_to complete_lesson_path(@lesson)
      render 'full_form'
    end
  end

  def confirm_reservation
    if @ticket.deposit_status != 'confirmed'
        if @ticket.booking_order_value.nil?
          amount_in_cents = (@ticket.price.to_f*100).to_i
        else
          amount_in_cents= (@ticket.booking_order_value.to_f*100).to_i
        end
            # :api_key => ENV['SECRET_KEY_SLEDDING'] #sledding key
          customer = Stripe::Customer.create({
            email: params[:stripeEmail],
            source:  params[:stripeToken]
          },
          { api_key: ENV['SECRET_KEY_SLEDDING']})

          charge = Stripe::Charge.create({
            customer: customer.id,
            amount: amount_in_cents,
            description: 'Sledding reservation payment',
            currency: 'usd'            
          },
          { api_key: ENV['SECRET_KEY_SLEDDING']})
        @ticket.deposit_status = 'confirmed'
        #at time of deposit, record the transaction amount as ticket_price, that way if pricing changes later, can calculate diff.
        @ticket.booking_order_value = @ticket.price
        if @ticket.is_gift_voucher?
          @ticket.state = 'gift_voucher_reserved'
        else
          @ticket.state = 'booked'
        end
        puts "!!!!!About to save state & deposit status after processing tickets#update"
        @ticket.save
      GoogleAnalyticsApi.new.event('lesson-requests', 'deposit-submitted', params[:ga_client_id])
      if @ticket.promo_code
        LessonMailer.send_sledding_promo_redemption_notification(@ticket).deliver!
      end
      if current_user && current_user.user_type == "Snow Schoolers Employee"
        @ticket.agent_id = current_user.id
      end
      LessonMailer.send_sledding_confirmation(@ticket).deliver!
        flash[:notice] = 'Thank you, your tickets have been purchased successfully! If you have any questions, please email hello@snowschoolers.com.'        
        flash[:conversion] = 'TRUE'
      puts "!!!!!!!! Sledding reservation successfully booked"
    end
      redirect_to "/tickets/#{@ticket.id}?state=#{@ticket.state}"
  end

  def reissue_invoice
    @lesson_time = @ticket.lesson_time
    @ticket.state == "ready_to_book"
    @ticket.deposit_status = 'pending_new_payment'
    @ticket.save
    render 'full_form'
  end

  def admin_confirm_cash
    @ticket.deposit_status = 'confirmed'
    @ticket.state = 'booked'
    @ticket.payment_method = 'cash'
    @ticket.check_in_status = 'checked-in'
    @ticket.save
    LessonMailer.send_sledding_confirmation(@ticket).deliver!
    flash[:notice] = "Success! Successfully recorded a cash payment for this booking."
    redirect_to "/tickets/#{@ticket.id}?state=#{@ticket.state}&admin_cash_payment=true"
  end  

  def admin_confirm_square
    @ticket.deposit_status = 'confirmed'
    @ticket.state = 'booked'
    @ticket.payment_method = 'square'
    @ticket.check_in_status = 'checked-in'
    @ticket.save
    LessonMailer.send_sledding_confirmation(@ticket).deliver!
    flash[:notice] = "Success! Successfully recorded a square payment for this booking."
    redirect_to "/tickets/#{@ticket.id}?state=#{@ticket.state}&admin_square_payment=true"
  end  

  def admin_confirm_split_charge
    @ticket.deposit_status = 'confirmed'
    @ticket.state = 'booked'
    @ticket.payment_method = 'square_split_charge'
    @ticket.save
    LessonMailer.send_sledding_confirmation(@ticket).deliver!
    flash[:notice] = "Success! Successfully recorded a square payment for this booking."
    redirect_to "/tickets/#{@ticket.id}?state=#{@ticket.state}&admin_split_charge=true"
  end  

  def sledding_check_in
      @ticket = Ticket.find(params[:id])
      @ticket.check_in_status = 'checked-in'
      @ticket.save
      redirect_back(fallback_location: tickets_path)
  end

  def sledding_check_in_reverse
      @ticket = Ticket.find(params[:id])
      @ticket.check_in_status = nil
      @ticket.save
      redirect_back(fallback_location: tickets_path)
  end

  def roster_today
    # Lesson.set_dates_for_sample_bookings
    @agent_id = params[:agent_id]
    @tickets_to_export = Ticket.all.select{|ticket| ticket.state == "confirmed" && ticket.date == Date.today}
    @tickets = Ticket.all.select{|ticket| ticket.booked? }
    @tickets = @tickets.select{ |ticket| ticket.date == Date.today}
    # @tickets = @tickets.sort! { |a,b| a.id <=> b.id }
    respond_to do |format|
          format.html {render 'index'}
          format.csv { send_data @tickets_to_export.to_csv, filename: "group-tickets-export-#{Date.today}.csv" }
    end
  end

  def roster_today_print
    @tickets = Ticket.all.select{|ticket| ticket.booked?}
    @tickets = @tickets.select{ |ticket| ticket.date == Date.today}
    @tickets = @tickets.sort! { |a,b| a.id <=> b.id }
    respond_to do |format|
          format.html {render 'index', layout: 'liability_release_layout'}
    end
  end

  def roster_tomorrow
    # ticket.set_dates_for_sample_bookings
    @tickets_to_export = Ticket.all.select{|ticket| ticket.state == "confirmed" && ticket.date == Date.tomorrow}
    @tickets = Ticket.all.select{|ticket| ticket.booked? }
    @tickets = @tickets.select{ |ticket| ticket.date == Date.tomorrow}
    @tickets = @tickets.sort! { |a,b| a.id <=> b.id }
    respond_to do |format|
          format.html {render 'index'}
          format.csv { send_data @tickets_to_export.to_csv, filename: "group-tickets-export-#{Date.today}.csv" }
    end
  end

  def future_sledding_roster
    @date = params[:date]
    @date.nil? ? @date = Date.today+2 : @date
    tickets = Ticket.all.to_a.keep_if{|ticket| ticket.booked? && ticket.date.to_s == @date && !ticket.canceled? }
    tickets = tickets.sort_by{|tickets| tickets.id}
    @tickets = tickets
  end  

  def roster_tomorrow_print
    @tickets = Ticket.all.select{|ticket| ticket.booked? }
    @tickets = @tickets.select{ |ticket| ticket.date == Date.tomorrow}
    @tickets = @tickets.sort! { |a,b| a.id <=> b.id }
    respond_to do |format|
          format.html {render 'index', layout: 'liability_release_layout'}
    end
  end

  # def capacity_today
  #   if params[:date]
  #       @date = params[:date].to_date
  #     # elsif Date.today <= "2020-11-27".to_date
  #       # min_date = "2020-11-27".to_date
  #     else @date = Date.today
  #   end
  #   # tickets = Ticket.where(state:"booked")
  #   # @tickets = tickets.select{ |ticket| ticket.booked? && ticket.date == @date }
  #   # @count = @tickets.count
  #   @tickets = Ticket.last(10)
  #   render 'capacity_calendar'
  # end

  def capacity_today
    if params[:date]
        min_date = params[:date].to_date
      elsif Date.today <= "2020-11-27".to_date
        min_date = "2020-11-27".to_date
      else min_date = Date.today - 4
    end
    max_date = min_date + 10
    tickets = Ticket.all.select{|ticket| ticket.booked? }
    tickets = tickets.select{ |ticket| ticket.date >= min_date && ticket.date <= max_date}
    @tickets = tickets.sort_by{|ticket| ticket.date}
    @count = @tickets.count
    dates = []
    (0..9).each do |x|
      dates << min_date + x
    end
    @dates = dates    
    render 'capacity_calendar'
  end

  def assign_tix_to_sessions 
    Ticket.assign_session_to_tix_without_session_details
    redirect_to capacity_calendar_path
  end

  def issue_refund
    @lesson_time = @ticket.lesson_time
    session[:refund] = true
    render 'full_form'
  end

  def mark_sledding_ticket_refunded
    @ticket = Ticket.find(params[:id])
    @ticket.skip_validations = true
    @ticket.state = 'Reservation canceled and refund has been issued.'
    @ticket.save
    session[:refund] = nil
    redirect_to @ticket
  end


  def check_user_permissions
    return unless @ticket.guest_email.nil?
  end  

  # DELETE /tickets/1
  # DELETE /tickets/1.json
  def destroy
    @ticket.destroy
    respond_to do |format|
      format.html { redirect_to tickets_url, notice: 'Ticket was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ticket_params
      params.require(:ticket).permit(:requester_id, :deposit_status, :lesson_time_id, :activity, :requested_location, :requester_name, :phone_number, :state, :actual_start_time, :terms_accepted, :guest_email, :how_did_you_hear, :num_days, :booking_order_value, :is_gift_voucher, :gift_recipient_email, :gift_recipient_name, :product_id, :admin_price_adjustment, :promo_code_id, :planned_start_time, :payment_status, :payment_method, :payment_date, :additional_info, :ticket_type, :street_address, :city, :state_code, :zip_code, :drivers_license, :skip_validations, :administrator_notes, :multi_product_order, :refund_issued, :check_in_status, :sleds_purchased, :free_participants_redeemed, :retail_item_name, :retail_item_quantity, :retail_item_price, :agent_adjustment_memo, :agent_id, :agent_adjustment_amount,
      lesson_time_attributes: [:date, :slot],
      participants_attributes: [:id, :name, :age_range, :gender, :_destroy, :guest_type, :requester_id], 
      )
    end

    def lesson_time_params
      params[:ticket].require(:lesson_time).permit(:date, :slot)
    end

end
