class CalendarBlocksController < ApplicationController
  before_action :set_calendar_block, only: [:show, :edit, :update, :destroy, :toggle_availability]

  # GET /calendar_blocks
  # GET /calendar_blocks.json
  def index
    if current_user.email == "brian@snowschoolers.com"
      @calendar_blocks = CalendarBlock.all.sort{ |a,b| a.lesson_time.date <=> b.lesson_time.date}
      else
      @calendar_blocks = CalendarBlock.where(instructor_id:current_user.instructor.id).sort{ |a,b| a.lesson_time.date <=> b.lesson_time.date}
    end
  end

  def refresh_calendar
    respond_to do |format|
    format.js {render inline: "location.reload();" }
    end
  end

  def availability
      if CalendarBlock.where(instructor_id:current_user.instructor.id).count == 0
          CalendarBlock.open_all_weekends(current_user.instructor.id)
          flash[:notice] = "Please set your availability below. We've temporarily marked all weekend days as available."
      end
      @calendar_blocks = CalendarBlock.where(instructor_id:current_user.instructor.id)
      @available_days = CalendarBlock.where(instructor_id:current_user.instructor.id,state:'Available')
      @instructor = current_user.instructor
  end

  def individual_availability
      instructor_id = params[:id]
      @calendar_blocks = CalendarBlock.where(instructor_id:instructor_id)
      @available_days = CalendarBlock.where(instructor_id:instructor_id,state:'Available')
      @instructor = Instructor.find(instructor_id)
      render 'availability'
  end

  def set_all_days_available
    instructor_id = current_user.instructor.id
    CalendarBlock.open_all_days(instructor_id)
    redirect_to '/my-availability'
  end

  def block_all_days
    instructor_id = current_user.instructor.id
    CalendarBlock.block_all_days(instructor_id)
    redirect_to '/my-availability'
  end

  def set_all_weekends_available
    instructor_id = current_user.instructor.id
    CalendarBlock.open_all_weekends(instructor_id)
    redirect_to '/my-availability'
  end

  
  def toggle_availability
    if @calendar_block.state == "Booked"
      return false 
    end
    @calendar_blocks = CalendarBlock.where(instructor_id:current_user.instructor.id)
    @available_days = CalendarBlock.where(instructor_id:current_user.instructor.id,state:'Available')
    @instructor = current_user.instructor
    puts "!!! calendar block id is #{@calendar_block.id}"
    @calendar_block.toggle_availability
    respond_to do |format|
      if @calendar_block.save
        format.html {render 'availability', notice: 'availability has been updated.'}
        format.json {render json: @calendar_block, callback: "changeText" }
      else
        format.html { render action: 'availability' }
        format.json { render json: @calendar_block.errors, status: :unprocessable_entity }
      end
    end
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def calendar_block_params
      params.require(:calendar_block).permit(:instructor_id, :lesson_time_id, :status, :date, :state, :prime_day)
    end

    def lesson_time_params
      params[:calendar_block].require(:lesson_time).permit(:date, :slot)
    end

end
