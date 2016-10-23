class SnowboardLevelsController < ApplicationController
  before_action :set_snowboard_level, only: [:show, :edit, :update, :destroy]

  # GET /snowboard_levels
  # GET /snowboard_levels.json
  def index
    @snowboard_levels = SnowboardLevel.all
  end

  # GET /snowboard_levels/1
  # GET /snowboard_levels/1.json
  def show
  end

  # GET /snowboard_levels/new
  def new
    @snowboard_level = SnowboardLevel.new
  end

  # GET /snowboard_levels/1/edit
  def edit
  end

  # POST /snowboard_levels
  # POST /snowboard_levels.json
  def create
    @snowboard_level = SnowboardLevel.new(snowboard_level_params)

    respond_to do |format|
      if @snowboard_level.save
        format.html { redirect_to @snowboard_level, notice: 'Snowboard level was successfully created.' }
        format.json { render action: 'show', status: :created, location: @snowboard_level }
      else
        format.html { render action: 'new' }
        format.json { render json: @snowboard_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /snowboard_levels/1
  # PATCH/PUT /snowboard_levels/1.json
  def update
    respond_to do |format|
      if @snowboard_level.update(snowboard_level_params)
        format.html { redirect_to @snowboard_level, notice: 'Snowboard level was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @snowboard_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /snowboard_levels/1
  # DELETE /snowboard_levels/1.json
  def destroy
    @snowboard_level.destroy
    respond_to do |format|
      format.html { redirect_to snowboard_levels_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_snowboard_level
      @snowboard_level = SnowboardLevel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def snowboard_level_params
      params.require(:snowboard_level).permit(:name, :value)
    end
end
