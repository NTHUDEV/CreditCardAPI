require 'sinatra'
require 'rbnacl/libsodium'
require 'config_env'
require_relative './model/credit_card.rb'
require_relative './helpers/kapian_helper'

class CreditCardAPI < Sinatra::Base
include KapianHelper
configure :development, :test do
  ConfigEnv.path_to_config("./config/config_env.rb")
  require 'hirb'
  Hirb.enable
end

#API
get '/api/v1/' do
  "CreditCardAPI by Enigma Manufacturing is up and running."
end

get '/api/v1/index' do
  begin

    halt 200, CreditCard.all.to_json

  rescue Exception => e
    halt 500, "All these moments will be lost in time like tears in the rain. -Roy Batty. Please punch your app dev in the face and show this #{e}."
  end
end

get '/api/v1/credit_card/validate' do
  content_type :json
  halt 401, 'Unauthorized' unless authenticate(env['HTTP_AUTHORIZATION'])
  creditcard = CreditCard.new
  creditcard.number = params[:card_number]
  {card: creditcard.number, validated: creditcard.validate_checksum}.to_json
end

get '/api/v1/credit_card' do
  begin
    content_type :json
    halt 401, 'Unauthorized' unless authenticate(env['HTTP_AUTHORIZATION'])
    halt 401, 'Unauthorized' unless @user_id == params[:user_id]
    halt 200, CreditCard.where(user_id: params[:user_id]).to_json
rescue Exception => e
  halt 500, "All these moments will be lost in time like tears in the rain. -Roy Batty. Please punch your app dev in the face and show this #{e}."
end
end

post '/api/v1/credit_card' do
  begin
    content_type :json
    halt 401, 'Unauthorized, no info.' unless authenticate(env['HTTP_AUTHORIZATION'])
    halt 401, 'Unauthorized, user does not match' unless @user_id == params[:user_id]
    request_json = request.body.read
    req = JSON.parse(request_json)
    creditcard = CreditCard.new(:number => req['card_number'].to_s,:expiration_date => req['expiration_date'].to_s,:owner => req['owner'].to_s,:credit_network => req['credit_network'].to_s, :user_id => @user_id)
    halt 400, "Whoa! Did you made a mistake or are you trying to trick the system?" unless creditcard.validate_checksum
    creditcard.save
    halt 201, "Welcome to the wonderful family of Enigma Mfg. We shall splurge on fancy equipment for our office with your credit card."
  rescue
    halt 410, "I'm sorry Dave, I'm afraid I can't do that. -HAL9000"
  end
end

end
