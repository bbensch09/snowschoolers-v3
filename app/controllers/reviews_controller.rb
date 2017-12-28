class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:create, :new, :update]

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = Review.all
    @reviews = @reviews.to_a.keep_if { |review| review.lesson_id != nil}
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
  end

  # GET /reviews/new
  def new
    @review = Review.new
  end

  # GET /reviews/1/edit
  def edit
  end

  # POST /reviews
  # POST /reviews.json
  def create
    @review = Review.new(review_params)

    respond_to do |format|
      if @review.save
        if @review.lesson
          @review.lesson.state = "waiting for payment"
          LessonMailer.new_review_submitted(@review).deliver!
          @review.lesson.save
        format.html { redirect_to @review.lesson, notice: "Thanks! If you feel it is deserved, please consider providing a tip for your instructor." }
        format.json { render action: 'show', status: :created, location: @review }
        else
          format.html { redirect_to @review.instructor, notice: "Admin has successfully created a review." }
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    respond_to do |format|
      if @review.update(review_params)
        @review.lesson.state = "waiting for payment"
        LessonMailer.new_review_submitted(@review).deliver!
        @review.lesson.save
        format.html { redirect_to @review.lesson, notice: 'Thanks for updating your review! Hope to see you back on the mountain soon.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review.destroy
    respond_to do |format|
      format.html { redirect_to reviews_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def review_params
      params.require(:review).permit(:instructor_id, :lesson_id, :reviewer_id, :rating, :review, :nps)
    end
end
