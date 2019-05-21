class EventsController < ApplicationController
  skip_before_action :check_nexmo_api_credentials, only: [:raw]
  skip_before_action :set_nexmo_app, only: [:raw]

  def index
  end

  def raw
    if params[:api_key].blank?
      head :forbidden and return
    end
    since = params[:since] || (60.minutes.ago.to_i).to_s
    since_date = DateTime.strptime(since,'%s')
    if params['type'].blank?
      events = EventLog.where("created_at > ?", since_date)
    else 
      events = EventLog.where("event_type = ? AND created_at > ?", params['type'], since_date)
    end
    response = ""
    events.each do |event|
      response += '<p id="' + event.id.to_s + '" class="app_event'
      if since.to_i > 0 
        if event.content.include? '"status":"started"'
          response += " alert alert-info"
        elsif event.content.include? '"status":"answered"'
          response += " alert alert-success"
        elsif event.content.include? '"status":"ringing"'
          response += " alert alert-danger"
        elsif event.content.include? '"status":"completed"'
          response += " alert alert-warning"
        else
          response += " alert alert-secondary"
        end
      end
      response += '" style="display:none;">'
      response += "<strong>#{event.created_at}</strong><br/>#{event.content}</p>"
      response += ' <script>$("#' + event.id.to_s + '").effect("highlight", 2000).show("fade", 1000);</script>'
    end
    render plain: response
  end

end
