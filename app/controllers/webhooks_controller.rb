require "redis"

class WebhooksController < ApplicationController

  skip_before_action :check_nexmo_api_credentials
  skip_before_action :verify_authenticity_token


  def answer
    if @nexmo_app.call_whisper?
      client = Redis.new

      case params[:from_user]
      when 'Jane'
        client.set("whisper_session_id", params[:conversation_uuid]) if client.get("whisper_session_id").blank?
        client.set("whisper_agent_leg_id", params[:uuid])
        ncco = Ncco.call_whisper_agent
      when 'Joe'
        client.set("whisper_session_id", params[:conversation_uuid]) if client.get("whisper_session_id").blank?
        client.set("whisper_supervisor_leg_id", params[:uuid])
        ncco = Ncco.call_whisper_supervisor
      else
        client.set("whisper_session_id", params[:conversation_uuid]) if client.get("whisper_session_id").blank?
        client.set("whisper_customer_leg_id", params[:uuid])
        ncco = Ncco.call_whisper_customer
      end 

      if client.get("whisper_session_id").blank?
        render json: { error: "Conversation not found" }, status: :bad_request
        return
      end
      
      ncco.gsub!("CONVERSATION_ID", client.get("whisper_session_id"))
      ncco.gsub!("AGENT_LEG_ID", client.get("whisper_agent_leg_id") || "")
      ncco.gsub!("SUPERVISOR_LEG_ID", client.get("whisper_supervisor_leg_id") || "")
      ncco.gsub!("CUSTOMER_LEG_ID", client.get("whisper_customer_leg_id") || "")
      render json: ncco
      return
    end

    ncco = @nexmo_app.voice_answer_ncco({webhooks_dtmf_url: webhooks_dtmf_url})
    if ncco.blank?
      render json: []
      return
    end
    ncco.gsub!("PARAMS_TO", (params[:to] || ""))
    render json: ncco
  end

  def event
    # logger.debug request.body.read
    EventLog.create(event_type: 'voice', content: request.body.read)
    head :ok
  end

  def dtmf
    # params.each do |key,value|
    #   Rails.logger.warn "Param #{key}: #{value}"
    # end
    case params[:dtmf]
    when "1"
      render json: Ncco.ivr_jane
    when "2"
      render json: Ncco.ivr_joe
    else 
      head :ok
    end
  end

end
