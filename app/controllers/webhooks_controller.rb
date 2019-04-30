class WebhooksController < ApplicationController

  skip_before_action :check_nexmo_api_credentials
  skip_before_action :verify_authenticity_token


  def answer
    render json: @nexmo_app.voice_answer_ncco || []
  end

  def event
    # logger.debug request.body.read
    EventLog.create(event_type: 'voice', content: request.body.read)
    head :ok
  end


end
