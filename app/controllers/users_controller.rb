class UsersController < ApplicationController
  before_action :set_user, only: [:show, :jwt, :edit, :update, :destroy]

  private 

  def set_user
    @user = User.find(params[:id])
  end


  public

  def index
    User.retrieve_all(@nexmo_app)
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if !@user.user_name.blank? && NexmoApi.create_user(@user.user_name, @nexmo_app) && @user.save
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if !NexmoApi.delete_user(@user, @nexmo_app)
      redirect_to users_path, notice: 'User could not be destroyed.'
      return
    end
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def jwt
    if @nexmo_app.private_key.blank?
      redirect_to user_path(@user), notice: 'Your Nexmo app does not have a private key'
    end
    @user.generate_jwt(@nexmo_app)
    redirect_to user_path(@user), notice: 'User JWT was successfully created.'
  end


  private 
  def user_params
    params.require(:user).permit(:user_name)
  end

end
