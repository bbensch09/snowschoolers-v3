class RentalsController < ApplicationController
  before_action :set_rental, only: [:show, :edit, :update, :destroy, :select_resource, :remove_resource]
  skip_before_action :authenticate_user!, except: [:index]

  # GET /rentals
  # GET /rentals.json
  def index
    if current_user.email == "brian@snowschoolers.com" || current_user.user_type == "Snow Schoolers Employee" || current_user.user_type == "Ski Area Partner"
      @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.booked? }
      @lessons = @lessons.select{|lesson| lesson.this_season? && lesson.includes_rental_package? && !lesson.canceled?}
      @past_lessons = @lessons.select{|lesson| lesson.lesson_time.date < Date.today }
      @lessons = @lessons.select{|lesson| lesson.lesson_time.date >= Date.today }
      @lessons.sort! { |a,b| a.lesson_time.date <=> b.lesson_time.date }
      @todays_lessons = Lesson.all.to_a.keep_if{|lesson| lesson.date == Date.today && lesson.includes_rental_package? }
      else
        @lessons = current_user.lessons
        @todays_lessons = current_user.lessons.to_a.keep_if{|lesson| lesson.date == Date.today }
    end
    # @rentals = Rental.all
  end

  def rentals_today
      @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.canceled? || lesson.booked? || lesson.state.nil? }
      @lessons = @lessons.select{|lesson| lesson.this_season? && lesson.includes_rental_package?}
      @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.date == Date.today}
      render 'index'
  end

  def rentals_tomorrow
      @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.canceled? || lesson.booked? || lesson.state.nil? }
      @lessons = @lessons.select{|lesson| lesson.this_season? && lesson.includes_rental_package?}
      @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.date == Date.tomorrow}
      render 'index'
  end

  def view_reservation
    @lessons = []
    @lessons << Lesson.find(params[:id])
    render 'index'
  end

  def past_rentals_index
      if current_user.email == "brian@snowschoolers.com" || current_user.user_type == "Snow Schoolers Employee" || current_user.user_type == "Ski Area Partner"
      @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.canceled? || lesson.booked? || lesson.state.nil? }
      @lessons = @lessons.select{|lesson| lesson.this_season? && lesson.includes_rental_package?}
      @lessons = @lessons.select{|lesson| lesson.lesson_time.date < Date.today }
      @lessons.sort! { |a,b| a.lesson_time.date <=> b.lesson_time.date }
      @todays_lessons = Lesson.all.to_a.keep_if{|lesson| lesson.date == Date.today && lesson.includes_rental_package? }
      else
        @lessons = current_user.lessons
        @todays_lessons = current_user.lessons.to_a.keep_if{|lesson| lesson.date == Date.today }
      end
      render 'index'
  end

  def admin_index
    @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed?}
    @lessons.sort! { |a,b| a.lesson_time.date <=> b.lesson_time.date }
  end


  # GET /rentals/1
  # GET /rentals/1.json
  def show
  end

  # GET /rentals/new
  def new
    @rental = Rental.new
  end

  # GET /rentals/1/edit
  def edit
    @resources = Resource.search(@rental)
    puts "!!!!!!! there are #{@resources.count} resources found"
  end

  def select_resource
    puts "!!! params are #{params[:resource_id]}"
    @rental.resource_id = params[:resource_id]
    @rental.status = "Reserved"
    @rental.save!
    redirect_to view_reservation_path(@rental.lesson.id)
  end

  def remove_resource
    @rental.resource_id = nil
    @rental.status = "Needs Equipment"
    @rental.save!
    redirect_to view_reservation_path(@rental.lesson.id)
  end


  # POST /rentals
  # POST /rentals.json
  def create
    @rental = Rental.new(rental_params)

    respond_to do |format|
      if @rental.save
        format.html { redirect_to @rental, notice: 'Rental was successfully created.' }
        format.json { render :show, status: :created, location: @rental }
      else
        format.html { render :new }
        format.json { render json: @rental.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rentals/1
  # PATCH/PUT /rentals/1.json
  def update
    respond_to do |format|
      if @rental.update(rental_params)
        format.html { redirect_to view_reservation_path(@rental.lesson.id), notice: 'Rental was successfully updated.' }
        format.json { render :show, status: :ok, location: @rental }
      else
        format.html { render :edit }
        format.json { render json: @rental.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rentals/1
  # DELETE /rentals/1.json
  def destroy
    @rental.destroy
    respond_to do |format|
      format.html { redirect_to rentals_url, notice: 'Rental was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rental
      @rental = Rental.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rental_params
      params.require(:rental).permit(:lesson_id, :student_id, :status, :other, :resource_id, :resource_type)
    end
end
