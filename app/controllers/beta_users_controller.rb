class BetaUsersController < ApplicationController
  before_action :set_beta_user, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:new, :create]


  # GET /beta_users
  # GET /beta_users.json
  def index
    @beta_users = BetaUser.all.sort {|a,b| a.id <=> b.id}
  end

  # GET /beta_users/1
  # GET /beta_users/1.json
  def show
  end

  # GET /beta_users/new
  def new
    @beta_user = BetaUser.new
  end

  # GET /beta_users/1/edit
  def edit
  end

  # POST /beta_users
  # POST /beta_users.json
  def create
    @beta_user = BetaUser.new(beta_user_params)

    respond_to do |format|
      if @beta_user.save
        if @beta_user.user_type == "Jackson_promo"
          LessonMailer.notify_jackson_promo_user(@beta_user).deliver
          format.html { redirect_to jackson_hole_path, notice: 'Thanks for your interest. If it is after January 3rd, but before Jan 6th, please call us at 530-430-SNOW.' }
          format.json { render action: 'show', status: :created, location: @beta_user }
          elsif @beta_user.user_type == "powder_promo"
          LessonMailer.notify_powder_promo(@beta_user).deliver
          format.html { redirect_to powder_path, notice: "Thanks for your interest. We'll get back to you shortly. If you have any other questions feel free to call us at 530-430-SNOW." }
          format.json { render action: 'show', status: :created, location: @beta_user }
          elsif @beta_user.user_type == "beginner_concierge"
          LessonMailer.notify_beginner_concierge(@beta_user).deliver
          format.html { redirect_to beginners_guide_to_tahoe_path, notice: "Thanks for your interest. We'll get back to you shortly. If you have any other questions feel free to call us at 530-430-SNOW." }
          format.json { render action: 'show', status: :created, location: @beta_user }
          elsif @beta_user.user_type == "package_promo"
          LessonMailer.notify_package_promo(@beta_user).deliver
          format.html { redirect_to root_path, notice: "Thanks for your interest. We'll get back to you shortly. If you have any other questions feel free to call us at 530-430-SNOW." }
          format.json { render action: 'show', status: :created, location: @beta_user }
          elsif @beta_user.user_type == "march_madness"
          LessonMailer.notify_march_madness_signup(@beta_user).deliver
          format.html { redirect_to root_path, notice: "Thanks for your signing up. You should receive an email shorty with full instructions on how the contest will work." }
          format.json { render action: 'show', status: :created, location: @beta_user }
          elsif @beta_user.user_type == "team_offsite"
          LessonMailer.notify_team_offsite(@beta_user).deliver
          format.html { redirect_to root_path, notice: "Thanks for expressing interest. You should receive an email shorty from your dedicated trip planning concierge." }
          format.json { render action: 'show', status: :created, location: @beta_user }
          else
          LessonMailer.notify_admin_beta_user(@beta_user).deliver
          format.html { redirect_to root_path, notice: 'Thanks for signing up!' }
          format.json { render action: 'show', status: :created, location: @beta_user }
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @beta_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /beta_users/1
  # PATCH/PUT /beta_users/1.json
  def update
    respond_to do |format|
      if @beta_user.update(beta_user_params)
        format.html { redirect_to @beta_user, notice: 'Beta user was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @beta_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /beta_users/1
  # DELETE /beta_users/1.json
  def destroy
    @beta_user.destroy
    respond_to do |format|
      format.html { redirect_to beta_users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_beta_user
      @beta_user = BetaUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def beta_user_params
      params.require(:beta_user).permit(:email, :user_type, :phone_number)
    end
end
