require "redis"

class ApiController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_before_action :check_nexmo_api_credentials, only: [:jwt, :whisper, :queue_conversations]


  def jwt
    render json: {error: 'user_name required'} and return if params['user_name'].blank?
    render json: {error: 'mobile api key required'} and return if params['mobile_api_key'].blank?
    render json: {error: 'invalid mobile api key'} and return if params['mobile_api_key'] != ENV['MOBILE_API_KEY']

    User.retrieve_all(@nexmo_app)
    @app_user = User.where(user_name: params['user_name']).first

    if @app_user.blank?
      NexmoApi.create_user(params['user_name'], @nexmo_app)
      User.retrieve_all(@nexmo_app)
    end
    @app_user = User.where(user_name: params['user_name']).first
    head :service_unavailable and return if @app_user.blank?
    
    @app_user.generate_jwt(@nexmo_app)
    @app_user.reload
    
    render json: {
      "user_id": @app_user.user_id,
      "user_name": @app_user.user_name,
      "jwt": @app_user.jwt,
      "expires_at": @app_user.jwt_expires_at
      }
  end



  def whisper
    render json: {error: 'mobile api key required'} and return if params['mobile_api_key'].blank?
    render json: {error: 'invalid mobile api key'} and return if params['mobile_api_key'] != ENV['MOBILE_API_KEY']
    client = Redis.new
    conversation_id = client.get("whisper_conversation_id") || ""
    customer_leg_id = client.get("whisper_customer_leg_id") || ""
    agent_leg_id = client.get("whisper_agent_leg_id") || ""
    render json: {
      conversation_id: conversation_id,
      customer_leg_id: customer_leg_id,
      agent_leg_id: agent_leg_id
    }
  end

  def queue_conversations
    render json: {error: 'mobile api key required'} and return if params['mobile_api_key'].blank?
    render json: {error: 'invalid mobile api key'} and return if params['mobile_api_key'] != ENV['MOBILE_API_KEY']
    client = Redis.new
    conversations = (client.get("queue_conversations") || "").split(" || ").map { |info|
      conversation_components = info.split(",")
      if conversation_components.count == 4
        {
          msisdn: conversation_components[0],
          conversation_id: conversation_components[1],
          leg_id: conversation_components[2],
          timestamp: conversation_components[3]
        }
      end
    }

    render json: {
      conversations: conversations
    }
  end


end
