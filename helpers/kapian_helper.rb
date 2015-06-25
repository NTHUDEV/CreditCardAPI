
require 'rbnacl/libsodium'
require 'jwt'
require 'base64'

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

=begin
def update_cc_cache
  cc_list = CreditCard.where(user_id: @user_id).map {|c| {owner: c.owner, number: "xxxx-"+c.number.last(4), credit_network: c.credit_network, expiration_date: c.expiration_date}}
  cc_index = {user_id: @user_id, credit_cards: cc_list}
  settings.ops_cache.set(@user_id, cc_index.to_json)
  cc_index
end
=end

def update_cc_cache
  cc_list = CreditCard.where(user_id: '1').map {|c| {owner: c.owner, number: "xxxx-"+c.number.last(4), credit_network: c.credit_network, expiration_date: c.expiration_date}}
  cc_index = {user_id: '1', credit_cards: cc_list}
  settings.ops_cache.set('1', cc_index.to_json)
  cc_index
end

end
