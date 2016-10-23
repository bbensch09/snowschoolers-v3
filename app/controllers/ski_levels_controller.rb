class SkiLevelsController < ApplicationController
  before_action :set_ski_level, only: [:show, :edit, :update, :destroy]

  # GET /ski_levels
  # GET /ski_levels.json
  def index
    @ski_levels = SkiLevel.all
  end

  # GET /ski_levels/1
  # GET /ski_levels/1.json
  def show
  end

  # GET /ski_levels/new
  def new
    @ski_level = SkiLevel.new
  end

  # GET /ski_levels/1/edit
  def edit
  end

  # POST /ski_levels
  # POST /ski_levels.json
  def create
    @ski_level = SkiLevel.new(ski_level_params)

    respond_to do |format|
      if @ski_level.save
        format.html { redirect_to @ski_level, notice: 'Ski level was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ski_level }
      else
        format.html { render action: 'new' }
        format.json { render json: @ski_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ski_levels/1
  # PATCH/PUT /ski_levels/1.json
  def update
    respond_to do |format|
      if @ski_level.update(ski_level_params)
        format.html { redirect_to @ski_level, notice: 'Ski level was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ski_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ski_levels/1
  # DELETE /ski_levels/1.json
  def destroy
    @ski_level.destroy
    respond_to do |format|
      format.html { redirect_to ski_levels_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ski_level
      @ski_level = SkiLevel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ski_level_params
      params.require(:ski_level).permit(:name, :value)
    end
end
