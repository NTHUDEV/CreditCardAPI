
require 'rbnacl/libsodium'
require 'jwt'
require 'Base64'

module KapianHelper

def authenticate(authorization)
  begin
    scheme, jwt = authorization.split(' ')
    ui_key = OpenSSL::PKey::RSA.new(Base64.decode64(ENV['WEB_PUB_KEY']))
    payload, header = JWT.decode jwt, ui_key
    @user_id = payload['sub']
    result = (scheme =~ /^Bearer$/i) && (payload['iss'] == 'https://kapianweb.herokuapp.com')
    return result
  rescue
    false
  end

end

end
