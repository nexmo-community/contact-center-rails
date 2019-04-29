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

end