class UsersController < ApplicationController
  before_action :set_user, only: [:show, :jwt, :edit, :update, :destroy]

  private 

  def set_user
    @user = User.find(params[:id])
  end

  def retrieve_all_users(nexmo_app)
    existing_users = User.all
    user_ids_to_remove = existing_users.map { |u| u.id }
    api_users = NexmoApi.users(nexmo_app)
    api_users.each do |api_user|
      existing_user = User.find_by(user_name: api_user.name)
      puts existing_user.inspect
      if existing_user.blank?
        User.create(user_id: api_user.id, user_name: api_user.name)
      else 
        existing_user.update(user_id: api_user.id, user_name: api_user.name)
        user_ids_to_remove.delete(existing_user.id)
      end
    end
    user_ids_to_remove.each do |id|
      existing_user = User.find_by(id: id)
      existing_user.destroy unless existing_user.blank?
    end
  end

  public

  def index
    retrieve_all_users(@nexmo_app)
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
