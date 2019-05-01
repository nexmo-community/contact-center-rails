class AuthController < ApplicationController

  skip_before_action :check_nexmo_api_credentials, only: [:login, :login_do, :logout]
  skip_before_action :set_nexmo_app

  def login
    unless session[:api_key].blank? || session[:api_secret].blank?
      redirect_to app_url and return
    end
    render layout: 'simple'
  end


  # On login, the api key and secret are stored in session variables
  def login_do
    api_key = params[:api_key]
    api_secret = params[:api_secret]
    if !api_key.blank? && !api_secret.blank?
        session[:api_key] = api_key
        session[:api_secret] = api_secret
        redirect_to app_url, notice: "Logged in!"
    else
        redirect_to login_url, alert: "Api credentials are invalid"
    end
  end


  # On logout, the session variables are cleared
  def logout
    session[:api_key] = nil
    session[:api_secret] = nil
    redirect_to root_url, notice: "Logged out!"
  end


end
