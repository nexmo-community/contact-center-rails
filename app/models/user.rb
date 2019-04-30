class User < ApplicationRecord

  validates :user_id, uniqueness: true
  validates :user_name, uniqueness: true

  def generate_jwt(nexmo_app)
    rsa_private = OpenSSL::PKey::RSA.new(nexmo_app.private_key)
    expiry_time = Time.now.to_i + 86400       # 1 day
    payload = {
      "application_id": nexmo_app.app_id,
      "iat": Time.now.to_i,
      "jti": SecureRandom.uuid,
      "sub": self.user_name,
      "exp": expiry_time,   
      "acl": {
        "paths": {
          "/**": {}
        }
      }
    }
    new_token = JWT.encode payload, rsa_private, 'RS256'
    self.update(jwt: new_token, jwt_expires_at: Time.at(expiry_time))
  end

end
