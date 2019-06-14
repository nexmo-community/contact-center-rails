

class Ncco

  def self.inbound
    ncco = File.read(Rails.root.join('app', 'services', 'ncco_inbound.json'))
    return ncco
  end

  def self.outbound(nexmo_app)
    ncco = File.read(Rails.root.join('app', 'services', 'ncco_outbound.json'))
    unless nexmo_app.number_msisdn.blank?
      ncco.sub! 'YOUR_NEXMO_NUMBER', nexmo_app.number_msisdn
    end
    return ncco
  end

  def self.ivr(nexmo_app, dtmf_url)
    ncco = File.read(Rails.root.join('app', 'services', 'ncco_ivr.json'))
    ncco.sub! 'DTMF_URL', dtmf_url
    return ncco
  end
  def self.ivr_jane
    ncco = File.read(Rails.root.join('app', 'services', 'ncco_ivr_jane.json'))
    return ncco
  end
  def self.ivr_joe
    ncco = File.read(Rails.root.join('app', 'services', 'ncco_ivr_joe.json'))
    return ncco
  end

  def self.call_whisper_customer
    ncco = File.read(Rails.root.join('app', 'services', 'ncco_call_whisper_customer.json'))
    return ncco
  end
  def self.call_whisper_agent
    ncco = File.read(Rails.root.join('app', 'services', 'ncco_call_whisper_agent.json'))
    return ncco
  end
  def self.call_whisper_supervisor
    ncco = File.read(Rails.root.join('app', 'services', 'ncco_call_whisper_supervisor.json'))
    return ncco
  end


end
