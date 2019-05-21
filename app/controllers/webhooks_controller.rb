class WebhooksController < ApplicationController

  skip_before_action :check_nexmo_api_credentials
  skip_before_action :verify_authenticity_token


  def answer
    if @nexmo_app.voice_answer_ncco.blank?
      render json: []
      return
    end
    ncco = @nexmo_app.voice_answer_ncco.sub("PARAMS_TO", (params[:to] || ""))
    render json: ncco
  end

  def event
    # logger.debug request.body.read
    EventLog.create(event_type: 'voice', content: request.body.read)
    head :ok
  end


end
