class CalendarBlocksController < ApplicationController
  before_action :set_calendar_block, only: [:show, :edit, :update, :destroy, :toggle_availability]
  before_action :confirm_admin_permissions, only: [:admin_availability]
  before_action :set_instructor, only: [:individual_availability, :set_all_days_available, :set_all_weekends_available, :block_all_days]


  # GET /calendar_blocks
  # GET /calendar_blocks.json
  def index
    if current_user.email == "brian@snowschoolers.com" || current_user.user_type == "Snow Schoolers Employee"
      @calendar_blocks = CalendarBlock.all.sort{ |a,b| a.created_at <=> b.created_at}
      else
      @calendar_blocks = CalendarBlock.where(instructor_id:current_user.instructor.id).sort{ |a,b| a.created_at <=> b.created_at}
    end
  end

  def set_sledhill_capacity_via_calendar_block
        @calendar_block = CalendarBlock.new
        @date = Date.today
  end

  def refresh_calendar
    respond_to do |format|
    format.js {render inline: "location.reload();" }
    end
  end

  def availability
      if current_user.instructor && CalendarBlock.where(instructor_id:current_user.instructor.id).count == 0
          CalendarBlock.open_all_days(current_user.instructor.id)
          flash[:notice] = "Please set your availability below. We've temporarily marked all weekend days as available."
      end
      if current_user.instructor
        @calendar_blocks = CalendarBlock.where(instructor_id:current_user.instructor.id)
        # @available_days = CalendarBlock.where(instructor_id:current_user.instructor.id,state:'Available')
        @instructor = current_user.instructor
        params[:id] = current_user.instructor.id
      end
  end

  def individual_availability
      puts "!!!!instructor name is :#{@instructor.name}."
      @calendar_blocks = CalendarBlock.where(instructor_id:@instructor.id)
      # @available_days = CalendarBlock.where(instructor_id:instructor_id,state:'Available')      
      render 'availability'
  end

  def admin_calendar
    @calendar_blocks = CalendarBlock.where(state:'Available') + CalendarBlock.where(state:'Booked')
    render 'admin_availability'
  end

  def calendar_preview
    date = params[:date]
    date.nil? ? date = Date.today+2 : date.to_date
    min_date = date -10
    lessons = Lesson.all.select{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.booked? || lesson.state.nil? }
    lessons = lessons.to_a.keep_if{|lesson| lesson.date >= Date.today-10 && lesson.date <= Date.today+10 && !lesson.canceled?}
    @lessons = lessons.sort_by{|lesson| lesson.date}
    @count = @lessons.count
    dates = []
    (1..20).each do |x|
      dates << min_date + x
    end
    # last year lessons & dates
    lessons_last_year = Lesson.all.select{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.booked? || lesson.state.nil? }
    lessons_last_year = lessons_last_year.to_a.keep_if{|lesson| lesson.date >= Date.today-375 && lesson.date <= Date.today+375}
    @lessons_last_year = lessons_last_year.sort_by{|lesson| lesson.date}    
    @dates = dates
  end

  def set_all_days_available
    instructor_id = @instructor.id
    CalendarBlock.open_all_days(instructor_id)
    redirect_to individual_availability_path(@instructor.to_param)
  end

  def block_all_days
    instructor_id = @instructor.id
    CalendarBlock.block_all_days(instructor_id)
    redirect_to individual_availability_path(@instructor.to_param)
  end

  def set_all_weekends_available
    instructor_id = @instructor.id
    CalendarBlock.open_all_weekends(instructor_id)
    redirect_to individual_availability_path(@instructor.to_param)
  end

  
  def toggle_availability
    @calendar_block = CalendarBlock.find(params[:id])
    # if @calendar_block.state == "Booked"
    #   return false 
    # end
    # @calendar_blocks = CalendarBlock.where(instructor_id:current_user.instructor.id)
    # @available_days = CalendarBlock.where(instructor_id:current_user.instructor.id,state:'Available')
    # @instructor = current_user.instructor
    puts "!!! prepare to toggle available state of calendar block id: #{@calendar_block.id}"
    new_state = @calendar_block.toggle_availability
    puts "!!! calendar_block has been set to #{new_state}"
    if request.xhr?
      render json: @calendar_block
    end
    # respond_to do |format|
      # if @calendar_block.save
        # format.html {redirect_to 'availability', notice: 'availability has been updated.'}
        # format.json {render json: @calendar_block, callback: "success" }
      # else
      #   format.html { render action: 'availability' }
      #   format.json { render json: @calendar_block.errors, status: :unprocessable_entity }
      # end
    # end
  end

  # GET /calendar_blocks/1
  # GET /calendar_blocks/1.json
  def show
  end

  # GET /calendar_blocks/new
  def new
    @calendar_block = CalendarBlock.new
    @lesson_time = @calendar_block.lesson_time
    @instructor = current_user.instructor.id
  end

  # GET /calendar_blocks/1/edit
  def edit
    @instructor = current_user.instructor.id
    @lesson_time = @calendar_block.lesson_time
  end

  # POST /calendar_blocks
  # POST /calendar_blocks.json
  def create
    if params[:commit] == "Create calendar block"
      @calendar_block = CalendarBlock.new(calendar_block_params)
      @calendar_block.lesson_time = @lesson_time = LessonTime.find_or_create_by(lesson_time_params)

      respond_to do |format|
        if @calendar_block.save
          format.html { redirect_to @calendar_block, notice: 'Calendar block was successfully created.' }
          format.json { render action: 'show', status: :created, location: @calendar_block }
        else
          format.html { render action: 'new' }
          format.json { render json: @calendar_block.errors, status: :unprocessable_entity }
        end
      end

    elsif params[:commit] == "Create 10-week recurring block"
      @calendar_block = CalendarBlock.new(calendar_block_params)
      @calendar_block.lesson_time = @lesson_time = LessonTime.find_or_create_by(lesson_time_params)
      @calendar_block.save!
      (1..9).to_a.each do |week|
          puts "!!!!!!params are: #{calendar_block_params}"
          @lesson_time = LessonTime.create!(date:(CalendarBlock.last.lesson_time.date+7),slot:LessonTime.last.slot)
          @calendar_block = CalendarBlock.new(calendar_block_params)
          @calendar_block.lesson_time = @lesson_time
          @calendar_block.save
          end
        redirect_to calendar_blocks_path
    elsif params[:commit] == "Set new capacity Constraint"
      @calendar_block = CalendarBlock.new(calendar_block_params)
      @calendar_block.lesson_time = @lesson_time = LessonTime.find_or_create_by(lesson_time_params)

      respond_to do |format|
        if @calendar_block.save
          format.html { redirect_to @calendar_block, notice: 'Sledhill Capacity has been adjusted.' }
          format.json { render action: 'show', status: :created, location: @calendar_block }
        else
          format.html { render action: 'new' }
          format.json { render json: @calendar_block.errors, status: :unprocessable_entity }
        end
      end
    else
    end
  end

  # PATCH/PUT /calendar_blocks/1
  # PATCH/PUT /calendar_blocks/1.json
  def update
    puts "the lesson_time_params are #{lesson_time_params}"
    @calendar_block.lesson_time = @lesson_time = LessonTime.find_or_create_by(lesson_time_params)
    respond_to do |format|
      if @calendar_block.update(calendar_block_params)
        format.html { redirect_to @calendar_block, notice: 'Calendar block was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @calendar_block.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /calendar_blocks/1
  # DELETE /calendar_blocks/1.json
  def destroy
    @calendar_block.destroy
    respond_to do |format|
      format.html { redirect_to calendar_blocks_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_calendar_block
      @calendar_block = CalendarBlock.find(params[:id])
    end

    def set_instructor      
      names = params[:id].split("-")
      if names.first.to_i > 0
        @instructor = Instructor.find(params[:id])
      else
        names = params[:id].gsub("-"," ")
        puts "!!!names is #{names}."
        @instructor = Instructor.all.select{|instructor| instructor.name.parameterize == params[:id]}.first
      end
    end
  
    def calendar_block_params
      params.require(:calendar_block).permit(:instructor_id, :lesson_time_id, :status, :date, :state, :prime_day)
    end

    def lesson_time_params
      params[:calendar_block].require(:lesson_time).permit(:date, :slot)
    end

end
