class ApplicationController < ActionController::Base
  before_action :check_nexmo_api_credentials
  before_action :set_nexmo_app

  private

  def check_nexmo_api_credentials
    if session[:api_key].blank? || session[:api_secret].blank?
      redirect_to root_url and return
    end
    # @existing_apps = NexmoApi.apps(session[:api_key], session[:api_secret])
    # if @existing_apps == nil
    #   redirect_to logout_url and return
    # end
    @balance = NexmoApi.balance(session[:api_key], session[:api_secret])
  end


  def set_nexmo_app
    if NexmoApp.all.count != 1
      redirect_to app_reset_url and return
    end
    @nexmo_app = NexmoApp.first
  end


end
