class UsersController < ApplicationController
  before_action :require_admin, except: %i[ profile update_profile ]
  before_action :set_user, only: %i[ show edit update destroy update_profile]

  # GET /users
  def index
    role_array = helpers.user_roles
    @users = Current.client.users.select{|u| role_array.include?(u.roles.first)}
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_url, notice: "User was successfully destroyed."
  end

  def profile
    @user = Current.user
  end

  def update_profile
    respond_to do |format|
      if @user.update(user_params)
        # password and confirmation can be blank if only updating username
        format.html { redirect_to root_path, notice: 'Profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'profile' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:client_id, :email, :username, :full_name,{:roles => []}, :default_book, :password, :password_confirmation)
    end
end
