require 'net/http'
require 'base64'
require 'json'
require 'ostruct'
require 'openssl'


class NexmoApi


  def self.balance(api_key, api_secret)
    uri = URI("https://rest.nexmo.com/account/get-balance?api_key=#{api_key}&api_secret=#{api_secret}")
    request = Net::HTTP::Get.new(uri)
    request['Content-type'] = 'application/json'
    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(request)
    }
    return nil unless response.is_a?(Net::HTTPSuccess)
    balance = JSON.parse(response.body, object_class: OpenStruct)
    return balance.value
  end


  def self.app_create(nexmo_app, api_key, api_secret)
    uri = URI('https://api.nexmo.com/v2/applications/')
    request = Net::HTTP::Post.new(uri)
    auth = "Basic " + Base64.strict_encode64("#{api_key}:#{api_secret}")
    request['Authorization'] = auth
    request['Content-type'] = 'application/json'
    request.body = {
      name: nexmo_app.name, 
      keys: {
        public_key: nexmo_app.public_key
      }, 
      capabilities: {
        voice: {
          webhooks: {
            answer_url: {
              address: nexmo_app.voice_answer_url,
              http_method: nexmo_app.voice_answer_method
            },
            event_url: {
              address: nexmo_app.voice_event_url,
              http_method: nexmo_app.voice_event_method
            }
          }
        }
      }
    }.to_json
    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(request)
    }
    unless response.is_a?(Net::HTTPSuccess)
      puts "ERROR"
      puts response.body
      return false
    end

    jsonApp = JSON.parse(response.body, object_class: OpenStruct)
    nexmo_app.update(app_id: jsonApp.id)
    return true
  end

  
end