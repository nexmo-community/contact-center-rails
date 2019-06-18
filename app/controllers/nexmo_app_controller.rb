require "redis"

class NexmoAppController < ApplicationController
  skip_before_action :set_nexmo_app, only: [:setup, :create, :reset]


  def edit
    @dtmf_url = webhooks_dtmf_url
  end


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


  # NCCO updates

  def update_ncco_custom
    @nexmo_app.update(voice_answer_type: :custom)
    redirect_to app_url, notice: "NCCO was successfully updated."
  end

  def update_ncco_inbound
    @nexmo_app.update(voice_answer_type: :inbound_call)
    redirect_to app_url, notice: "NCCO was successfully updated."
  end

  def update_ncco_outbound
    @nexmo_app.update(voice_answer_type: :outbound_call)
    redirect_to app_url, notice: "NCCO was successfully updated."
  end

  def update_ncco_ivr
    @nexmo_app.update(voice_answer_type: :ivr)
    redirect_to app_url, notice: "NCCO was successfully updated."
  end
  def update_ncco_whisper
    client = Redis.new
    client.del("whisper_conversation_id")
    client.del("whisper_agent_leg_id")
    client.del("whisper_supervisor_leg_id")
    client.del("whisper_customer_leg_id")
    @nexmo_app.update(voice_answer_type: :call_whisper)
    redirect_to app_url, notice: "NCCO was successfully updated."
  end

  def update_ncco_queue
    client = Redis.new
    client.del("queue_conversations")
    @nexmo_app.update(voice_answer_type: :call_queue)
    redirect_to app_url, notice: "NCCO was successfully updated."
  end


  private

  def nexmo_app_params
    params.require(:nexmo_app).permit(:name, :voice_answer_type, :voice_answer_custom_ncco)
  end

end
