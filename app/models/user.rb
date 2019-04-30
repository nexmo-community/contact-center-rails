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

  def self.retrieve_all(nexmo_app)
    existing_users = User.all
    user_ids_to_remove = existing_users.map { |u| u.id }
    api_users = NexmoApi.users(nexmo_app)
    api_users.each do |api_user|
      existing_user = User.find_by(user_name: api_user.name)
      puts existing_user.inspect
      if existing_user.blank?
        User.create(user_id: api_user.id, user_name: api_user.name)
      else 
        existing_user.update(user_id: api_user.id, user_name: api_user.name)
        user_ids_to_remove.delete(existing_user.id)
      end
    end
    user_ids_to_remove.each do |id|
      existing_user = User.find_by(id: id)
      existing_user.destroy unless existing_user.blank?
    end
  end

end
