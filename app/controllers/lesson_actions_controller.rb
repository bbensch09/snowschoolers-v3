class LessonActionsController < ApplicationController
  before_action :set_lesson_action, only: [:show, :edit, :update, :destroy]
  before_action :confirm_admin_permissions

  # GET /lesson_actions
  # GET /lesson_actions.json
  def index
    @lesson_actions = LessonAction.all
  end

  # GET /lesson_actions/1
  # GET /lesson_actions/1.json
  def show
  end

  # GET /lesson_actions/new
  def new
    @lesson_action = LessonAction.new
  end

  # GET /lesson_actions/1/edit
  def edit
  end

  # POST /lesson_actions
  # POST /lesson_actions.json
  def create
    @lesson_action = LessonAction.new(lesson_action_params)

    respond_to do |format|
      if @lesson_action.save
        format.html { redirect_to @lesson_action, notice: 'Lesson action was successfully created.' }
        format.json { render action: 'show', status: :created, location: @lesson_action }
      else
        format.html { render action: 'new' }
        format.json { render json: @lesson_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lesson_actions/1
  # PATCH/PUT /lesson_actions/1.json
  def update
    respond_to do |format|
      if @lesson_action.update(lesson_action_params)
        format.html { redirect_to @lesson_action, notice: 'Lesson action was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @lesson_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lesson_actions/1
  # DELETE /lesson_actions/1.json
  def destroy
    @lesson_action.destroy
    respond_to do |format|
      format.html { redirect_to lesson_actions_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lesson_action
      @lesson_action = LessonAction.find(params[:id])
    end

    def confirm_admin_permissions
      return if current_user.email == 'brian@snowschoolers.com' || current_user.email == 'bbensch@gmail.com'
      redirect_to root_path, notice: 'You do not have permission to view that page.'
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lesson_action_params
      params.require(:lesson_action).permit(:lesson_id, :instructor_id, :action)
    end
end
