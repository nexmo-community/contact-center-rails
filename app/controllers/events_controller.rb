class EventsController < ApplicationController

  def index
  end

  def raw
    since = params[:since] || (60.minutes.ago.to_i).to_s
    since_date = DateTime.strptime(since,'%s')
    if params['type'].blank?
      events = EventLog.where("created_at > ?", since_date)
    else 
      events = EventLog.where("event_type = ? AND created_at > ?", params['type'], since_date)
    end
    render json: events.to_json
  end

end
