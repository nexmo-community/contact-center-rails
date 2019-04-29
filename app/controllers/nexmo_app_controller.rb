class NexmoAppController < ApplicationController
  before_action :set_nexmo_app, except: [:setup, :create, :reset]

  def update
    if @nexmo_app.update(nexmo_app_params)
      redirect_to app_url, notice: 'App was successfully updated.'
      return
    end
    render action: :edit, alert: 'Something went wrong' and return
  end



  # APP KEYS

  def public_key
    send_data @nexmo_app.public_key,
      :disposition => "attachment; filename=public.key"
  end
  def private_key
    send_data @nexmo_app.private_key,
      :disposition => "attachment; filename=private.key"
  end



  # APP SETUP

  def setup
    if NexmoApp.all.count > 0
      redirect_to app_url and return
    end
    @nexmo_app = NexmoApp.new
  end

  def create
    key = OpenSSL::PKey::RSA.generate(2048)
    @nexmo_app = NexmoApp.new(nexmo_app_params.merge({
      voice_answer_url: webhooks_answer_url, voice_answer_method: "GET",
      voice_event_url: webhooks_event_url, voice_event_method: "POST",
      public_key: key.public_key, private_key: key.to_s
    }))
    unless @nexmo_app.save
      render action: :setup, alert: 'Something went wrong' and return
    end
    unless NexmoApi.app_create(@nexmo_app, session[:api_key], session[:api_secret])
      redirect_to app_url, alert: 'Nexmo app was successfully created but could not be updated on the Nexmo servers.'
      return
    end
    redirect_to app_url, notice: "Nexmo app was successfully created."
  end

  def reset
    EventLog.destroy_all
    User.destroy_all
    NexmoApp.destroy_all
    redirect_to app_setup_url
  end



  private

  def nexmo_app_params
    params.require(:nexmo_app).permit(:name, :voice_answer_ncco)
  end

end
