require 'sinatra'
require 'rbnacl/libsodium'
require 'config_env'
require 'dalli'
require_relative './model/credit_card.rb'
require_relative './helpers/kapian_helper'

class CreditCardAPI < Sinatra::Base
include KapianHelper

configure :development, :test do
  ConfigEnv.path_to_config("./config/config_env.rb")
end

configure do
  require 'hirb'
  Hirb.enable

  set :ops_cache, Dalli::Client.new((ENV["MEMCACHIER_SERVERS"] || "").split(","),
  {
    :username => ENV["MEMCACHIER_USERNAME"],
    :password => ENV["MEMCACHIER_PASSWORD"],
    :socket_timeout => 1.5,
    :socket_failure_delay => 0.2
    })
end

#API PATHS
get '/api/v1/' do
  "CreditCardAPI by Enigma Manufacturing is up and running."
end

get '/api/v1/index' do
  begin

    halt 200, CreditCard.all.to_json

  rescue Exception => e
    halt 500, { status: "All these moments will be lost in time like tears in the rain. -Roy Batty. Please punch your app dev in the face and show this #{e}."}.to_json
  end
end

get '/api/v1/credit_card/validate' do
  content_type :json
  halt 401, {status: 'Unauthorized'}.to_json unless authenticate(env['HTTP_AUTHORIZATION'])
  creditcard = CreditCard.new
  creditcard.number = params[:card_number]
  {card: creditcard.number, validated: creditcard.validate_checksum}.to_json
end

get '/api/v1/credit_card' do
  begin
    content_type :json
    halt 401, {status: 'Unauthorized, info'}.to_json unless authenticate(env['HTTP_AUTHORIZATION'])
    halt 401, {status: 'Unauthorized, user'}.to_json unless @user_id == params[:user_id].to_i

    #halt 200, CreditCard.where(user_id: params[:user_id]).map {|c| {owner: c.owner, number: "xxxx-"+c.number.last(4), credit_network: c.credit_network, expiration_date: c.expiration_date}}.to_json
    halt 200, update_cc_cache.to_json
rescue Exception => e
  halt 500, "All these moments will be lost in time like tears in the rain. -Roy Batty. Please punch your app dev in the face and show this #{e}."
end
end

post '/api/v1/credit_card' do
  begin
    content_type :json
    halt 401, {status: 'Unauthorized, info'}.to_json unless authenticate(env['HTTP_AUTHORIZATION'])
    halt 401, {status: 'Unauthorized, user'}.to_json unless @user_id == params[:user_id].to_i
    request_json = request.body.read
    req = JSON.parse(request_json)
    creditcard = CreditCard.new(:number => req['card_number'].to_s,:expiration_date => req['expiration_date'].to_s,:owner => req['owner'].to_s,:credit_network => req['credit_network'].to_s, :user_id => @user_id)
    halt 400, {status: 'Whoa! Did you made a mistake or are you trying to trick the system?'}.to_json unless creditcard.validate_checksum
    creditcard.save
    update_cc_cache
    halt 201, {status: 'Welcome to the wonderful family of Enigma Mfg. We shall splurge on fancy equipment for our office with your credit card.'}.to_json
  rescue
    halt 410, {status: "I'm sorry Dave, I'm afraid I can't do that. -HAL9000"}.to_json
  end
end
end
