class NexmoApp < ApplicationRecord

  validates :name, presence: true
  enum voice_answer_type: [:inbound_call, :outbound_call, :ivr, :call_whisper]
  

  def voice_answer_ncco_descriptive(params)
    case self.voice_answer_type 
    when "inbound_call"
      "<h5>Inbound call</h5><pre>" + Ncco.inbound + "</pre>"
    when "outbound_call"
      "<h5>Outbound call</h5><pre>" + Ncco.outbound(self) + "</pre>"
    when "ivr"
      "<h5>IVR</h5><pre>" + Ncco.ivr(self, params[:webhooks_dtmf_url]) + "</pre>"
    when "call_whisper"
      "<h5>Call whisper</h5>"
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
