class NumbersController < ApplicationController

  def index
    @available_numbers = NexmoApi.numbers(session[:api_key], session[:api_secret])
  end

  def search
    @country = params[:country] || "GB"
    @available_numbers = NexmoApi.number_search(@country, session[:api_key], session[:api_secret])
  end

  def buy
    redirect_to numbers_url and return if (params[:country].blank? || params[:msisdn].blank?)
    if NexmoApi.number_buy(params[:country], params[:msisdn], session[:api_key], session[:api_secret])
      redirect_to numbers_url, notice: "#{params[:msisdn]} was successfully purchased."
    else
      redirect_to numbers_url, alert: "#{params[:msisdn]} could not be purchased."
    end
  end

  def add
    redirect_to numbers_url and return if (params[:country].blank? || params[:msisdn].blank?)
    unless @nexmo_app.number_msisdn.blank?
      NexmoApi.number_remove(@nexmo_app.app_id, @nexmo_app.number_country, @nexmo_app.number_msisdn, session[:api_key], session[:api_secret])
    end
    if NexmoApi.number_add(@nexmo_app.app_id, params[:country], params[:msisdn], session[:api_key], session[:api_secret])
      @nexmo_app.update(number_msisdn: params[:msisdn], number_country: params[:country])
      redirect_to numbers_url, notice: "#{params[:msisdn]} was successfully assigned to the app."
    else
      redirect_to numbers_url, alert: "#{params[:msisdn]} could not be assigned to the app."
    end
  end

  def remove
    redirect_to numbers_url and return if (params[:country].blank? || params[:msisdn].blank?)
    if NexmoApi.number_remove(@nexmo_app.app_id, params[:country], params[:msisdn], session[:api_key], session[:api_secret])
      @nexmo_app.update(number_msisdn: nil, number_country: nil)
      redirect_to numbers_url, notice: "#{params[:msisdn]} was successfully removed from the app."
    else
      redirect_to numbers_url, alert: "#{params[:msisdn]} could not be removed from the app."
    end
  end

end
