require "redis"


class NexmoApp < ApplicationRecord

  validates :name, presence: true
  enum voice_answer_type: [:inbound_call, :outbound_call, :ivr, :call_whisper]
  

  def voice_answer_ncco_descriptive(params)
    client = Redis.new
    
    case self.voice_answer_type 
    when "inbound_call"
      "<h5>Inbound call</h5><pre>" + Ncco.inbound + "</pre>"
    when "outbound_call"
      "<h5>Outbound call</h5><pre>" + Ncco.outbound(self) + "</pre>"
    when "ivr"
      "<h5>IVR - Main menu</h5><pre>" + Ncco.ivr(self, params[:webhooks_dtmf_url]) + "</pre>" +
      "<h5>Jane selection</h5><pre>" + Ncco.ivr_jane + "</pre>" +
      "<h5>Joe selection</h5><pre>" + Ncco.ivr_joe + "</pre>"
    when "call_whisper"
      "<h5>Call whisper</h5>" +
      "<pre>CONVERSATION_ID: " + (client.get("whisper_session_id") || "-") + 
      "\nAGENT_LEG_ID: " + (client.get("whisper_agent_leg_id") || "-" ) +
      "\nSUPERVISOR_LEG_ID: " + (client.get("whisper_supervisor_leg_id") || "-") +
      "\nCUSTOMER_LEG_ID: " + (client.get("whisper_customer_leg_id") || "-") +
      "</pre>"+
      "<h6>Customer</h6><pre>" + Ncco.call_whisper_customer + "</pre>" +
      "<h6>Agent</h6><pre>" + Ncco.call_whisper_agent + "</pre>" +
      "<h6>Supervisor</h6><pre>" + Ncco.call_whisper_supervisor + "</pre>"

    else 
      "<h5>Not set</h5>"
    end
  end

  def voice_answer_ncco(params)
    case self.voice_answer_type 
    when "inbound_call"
      Ncco.inbound
    when "outbound_call"
      Ncco.outbound(self)
    when "ivr"
      Ncco.ivr(self, params[:webhooks_dtmf_url])
    when "call_whisper"
      ""
    else 
      ""
    end
  end


end
