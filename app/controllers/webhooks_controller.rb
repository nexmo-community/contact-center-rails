require "redis"

class WebhooksController < ApplicationController

  skip_before_action :check_nexmo_api_credentials
  skip_before_action :verify_authenticity_token


  def answer
    answer_queue and return if @nexmo_app.call_queue?
    answer_whisper and return if @nexmo_app.call_whisper?

    ncco = @nexmo_app.voice_answer_ncco({webhooks_dtmf_url: webhooks_dtmf_url})
    if ncco.blank?
      render json: []
      return
    end
    ncco.gsub!("PARAMS_TO", (params[:to] || ""))
    render json: ncco
  end

  def answer_whisper
    client = Redis.new
    case params[:from_user]
    when 'Jane'
      client.set("whisper_conversation_id", params[:conversation_uuid]) if client.get("whisper_conversation_id").blank?
      client.set("whisper_agent_leg_id", params[:uuid])
      ncco = Ncco.call_whisper_agent
    when 'Joe'
      client.set("whisper_conversation_id", params[:conversation_uuid]) if client.get("whisper_conversation_id").blank?
      client.set("whisper_supervisor_leg_id", params[:uuid])
      ncco = Ncco.call_whisper_supervisor
    else
      client.set("whisper_conversation_id", params[:conversation_uuid]) if client.get("whisper_conversation_id").blank?
      client.set("whisper_customer_leg_id", params[:uuid])
      ncco = Ncco.call_whisper_customer
    end 

    if client.get("whisper_conversation_id").blank?
      render json: { error: "Conversation not found" }, status: :bad_request
      return
    end
    
    ncco.gsub!("CONVERSATION_ID", client.get("whisper_conversation_id"))
    ncco.gsub!("AGENT_LEG_ID", client.get("whisper_agent_leg_id") || "")
    ncco.gsub!("SUPERVISOR_LEG_ID", client.get("whisper_supervisor_leg_id") || "")
    ncco.gsub!("CUSTOMER_LEG_ID", client.get("whisper_customer_leg_id") || "")
    render json: ncco
  end

  def answer_queue
    client = Redis.new
    if params[:from_user] == "Jane"
      ncco = Ncco.call_queue_agent
      ncco.gsub!("CONVERSATION_NAME", "AGENT-#{params[:from_user]}")
    else
      ncco = Ncco.call_queue_customer
      conversations = (client.get("queue_conversations") ||  "").split(" || ")
      new_conversation = "#{params[:from]},#{params[:conversation_uuid]},#{params[:uuid]},#{Time.now.getutc.to_i}"
      puts conversations.inspect
      puts new_conversation
      conversations << new_conversation
      client.set("queue_conversations", conversations.join(" || "))
    end
    render json: ncco
  end



  def event
    # logger.debug request.body.read
    EventLog.create(event_type: 'voice', content: request.body.read)

    puts params.inspect

    # Process events

    client = Redis.new
    conversations = (client.get("queue_conversations") ||  "").split(" || ")

     # Conversation completed
     if !params[:status].blank? && params[:status] == "completed" 
      conversations = conversations.select do |conv|
        !conv.include?(params[:conversation_uuid])
      end
      puts "---------------------------------"
      puts "REMOVED conversation_uuid: #{params[:conversation_uuid]}"
      puts "status: #{params[:status]}"
      client.set("queue_conversations", conversations.join(","))
    end

    

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
