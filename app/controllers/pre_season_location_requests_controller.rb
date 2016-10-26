class PreSeasonLocationRequestsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  before_action :set_pre_season_location_request, only: [:show, :edit, :update, :destroy]

  # GET /pre_season_location_requests
  # GET /pre_season_location_requests.json
  def index
    @pre_season_location_requests = PreSeasonLocationRequest.all
  end

  # GET /pre_season_location_requests/1
  # GET /pre_season_location_requests/1.json
  def show
  end

  # GET /pre_season_location_requests/new
  def new
    @pre_season_location_request = PreSeasonLocationRequest.new
  end

  # GET /pre_season_location_requests/1/edit
  def edit
  end

  # POST /pre_season_location_requests
  # POST /pre_season_location_requests.json
  def create
    @pre_season_location_request = PreSeasonLocationRequest.new(pre_season_location_request_params)

    respond_to do |format|
      if @pre_season_location_request.save
        LessonMailer.notify_admin_preseason_request(@pre_season_location_request).deliver
        format.html { redirect_to '/lessons/new', notice: 'Thank you! Your opinion has been counted. Feel free to explore the rest of our website.' }
        format.json { render action: 'show', status: :created, location: @pre_season_location_request }
      else
        format.html { render action: 'new' }
        format.json { render json: @pre_season_location_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pre_season_location_requests/1
  # PATCH/PUT /pre_season_location_requests/1.json
  def update
    respond_to do |format|
      if @pre_season_location_request.update(pre_season_location_request_params)
        format.html { redirect_to @pre_season_location_request, notice: 'Pre season location request was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @pre_season_location_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pre_season_location_requests/1
  # DELETE /pre_season_location_requests/1.json
  def destroy
    @pre_season_location_request.destroy
    respond_to do |format|
      format.html { redirect_to pre_season_location_requests_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pre_season_location_request
      @pre_season_location_request = PreSeasonLocationRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pre_season_location_request_params
      params.require(:pre_season_location_request).permit(:name)
    end
end
