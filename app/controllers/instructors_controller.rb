class InstructorsController < ApplicationController
  before_action :set_instructor, only: [:show, :edit, :update, :destroy, :show_candidate]
  before_action :confirm_admin_permissions, except: [:create, :profile, :update, :new, :edit, :show, :thank_you, :browse, :show, :show_candidate]
  # before_action :confirm_user_permissions, only: [:edit, :update]
  skip_before_action :authenticate_user!, only: [:new, :create, :thank_you, :browse, :show, :show_candidate]


  def verify
    instructor = Instructor.find(params[:id])
    instructor.status = 'Active'
    instructor.mark_eligible_for_beginners
    instructor.save
    LessonMailer.instructor_status_activated(instructor).deliver
    redirect_to instructors_path, notice: "Instructor has been verified"
  end

  def revoke
    instructor = Instructor.find(params[:id])
    instructor.status = "Revoked"
    instructor.save
    redirect_to instructors_path, notice: "Instructor privileges have been revoked"
  end

  def profile
    @instructor = current_user.instructor
    render 'show'
  end

  # GET /instructors
  # GET /instructors.json
  def index
    # if current_user.user_type == "Partner"
    #   @instructors = Location.find(current_user.location_id).instructors.sort {|a,b| b.overall_initial_rank <=> a.overall_initial_rank}
    #   else
      @instructors = Instructor.all.sort {|a,b| a.status <=> b.status}
    # end
  end

  def admin_index
     @instructors = Instructor.all.sort {|a,b| a.id <=> b.id}
  end

  # GET /browse
  # GET /browse.json
  def browse
    puts "Session values stored: #{session[:lesson]}"
    @instructors = Instructor.where(status: "Active")
    @instructors = @instructors.to_a.keep_if {|instructor| instructor.ski_levels.any? || instructor.snowboard_levels.any? }
    @instructors.sort! {|a,b| b.reviews.count <=> a.reviews.count}
  end

  # GET /instructors/1
  # GET /instructors/1.json
  def show
  end

  def show_candidate
  end

  # GET /instructors/new
  def new
    if current_user.instructor
      @instructor = current_user.instructor
      @instructor_id = Instructor.find(params[:id]).user_id
      render 'edit'
      else
      @instructor = Instructor.new
      @instructor_id = nil
    end

  end

  # GET /instructors/1/edit
  def edit
        # @instructor_id = Instructor.find(params[:id]).user_id
        @instructor_id = @instructor.user_id
  end

  def thank_you
  end

  # POST /instructors
  # POST /instructors.json
  def create
    @instructor = Instructor.new(instructor_params)
    @instructor.user_id = current_user.id unless current_user.nil?
    @instructor.status = "new applicant"
    @instructor.overall_initial_rank = 1
    @instructor.kids_initial_rank = 1
    @instructor.adults_initial_rank = 1

    respond_to do |format|
      if @instructor.save
        # ga_test_cid = params[:ga_client_id]
        # puts "The GA ga_client_id is #{ga_test_cid}."
        session[:instructor_id] = @instructor.id
        flash[:application_submitted] = 'TRUE'
        GoogleAnalyticsApi.new.event('instructor-recruitment', 'new-application-submitted', params[:ga_client_id])
        format.html { redirect_to '/thanks-for-applying', notice: 'Your instructor application was successfully submitted, you will be contacted shortly. You may also reach out with questions to info@snowschoolers.com' }
        format.json { render action: 'show', status: :created, location: @instructor }
      else
        format.html { render action: 'new' }
        format.json { render json: @instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instructors/1
  # PATCH/PUT /instructors/1.json
  def update
    respond_to do |format|
      if @instructor.update(instructor_params)
        format.html { redirect_to instructor_path, notice: 'Your instructor application was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instructors/1
  # DELETE /instructors/1.json
  def destroy
    @instructor.destroy
    respond_to do |format|
      format.html { redirect_to instructors_url }
      format.json { head :no_content }
    end
  end

  private
    def confirm_user_permissions
      return if current_user.instructor == @instructor || current_user.email == 'brian@snowschoolers.com'
      redirect_to @instructor, notice: 'You do not have permission to edit this page.'
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_instructor
      @instructor = Instructor.find(params[:id])
      # names = params[:id].split("-")
      # first_name = names.first.titleize
      # last_name = names.last.titleize
      # @instructor = Instructor.where(first_name:first_name,last_name:last_name).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def instructor_params
      params.require(:instructor).permit(:first_name, :last_name, :username, :preferred_locations, :certification, :phone_number, :sport, :bio, :intro, :status, :city, :user_id, :avatar, :how_did_you_hear, :confirmed_certification, :kids_eligibility, :base_rate, :seniors_eligibility, :adults_eligibility, :kids_initial_rank, :adults_initial_rank, :overall_initial_rank, :age, :dob, sport_ids:[], location_ids:[], ski_level_ids:[], snowboard_level_ids:[])
    end
end
