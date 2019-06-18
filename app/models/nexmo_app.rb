require "redis"


class NexmoApp < ApplicationRecord

  validates :name, presence: true
  enum voice_answer_type: [:custom, :inbound_call, :outbound_call, :ivr, :call_whisper, :call_queue]
  

  def voice_answer_ncco_descriptive(params)
    client = Redis.new
    
    case self.voice_answer_type 
    when "custom"
      '<h5>Custom NCCO &nbsp; <a href="/app/edit" class="btn btn-outline-primary btn-sm">Edit</a></h5><pre>' + self.voice_answer_custom_ncco + "</pre>"
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
      "<pre>CONVERSATION_ID: " + (client.get("whisper_conversation_id") || "-") + 
      "\nAGENT_LEG_ID: " + (client.get("whisper_agent_leg_id") || "-" ) +
      "\nSUPERVISOR_LEG_ID: " + (client.get("whisper_supervisor_leg_id") || "-") +
      "\nCUSTOMER_LEG_ID: " + (client.get("whisper_customer_leg_id") || "-") +
      "</pre>"+
      "<h6>Customer</h6><pre>" + Ncco.call_whisper_customer + "</pre>" +
      "<h6>Agent</h6><pre>" + Ncco.call_whisper_agent + "</pre>" +
      "<h6>Supervisor</h6><pre>" + Ncco.call_whisper_supervisor + "</pre>"
    when "call_queue"
      "<h5>Call Queueing</h5>" +
      "<h6>Queued Calls: </h6><pre>" + (client.get("queue_conversations") || "").split(" || ").join("\n") +
      "</pre>"+
      "<h6>Customer NCCO</h6><pre>" + Ncco.call_queue_customer + "</pre>" +
      "<h6>Customer connect NCCO</h6><pre>" + Ncco.call_queue_customer_connect + "</pre>" +
      "<h6>Agent NCCO</h6><pre>" + Ncco.call_queue_agent + "</pre>"
    else 
      "<h5>Not set</h5>"
    end
  end

  def voice_answer_ncco(params)
    case self.voice_answer_type 
    when "custom"
      self.voice_answer_custom_ncco
    when "inbound_call"
      Ncco.inbound
    when "outbound_call"
      Ncco.outbound(self)
    when "ivr"
      Ncco.ivr(self, params[:webhooks_dtmf_url])
    else 
      ""
    end
  end


end
