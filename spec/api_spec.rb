require_relative 'spec_helper'

describe 'CreditCardAPI Stories' do
  #test 1
  describe 'Check service status' do
    it 'Should return all is well' do
      get '/api/v1/'
      last_response.body.must_include 'up and running'
      last_response.status.must_equal 200
    end
  end

  #test2
  describe 'Get all cards' do
    it 'should display all cards in db' do
      get '/api/v1/index'
      last_response.status.must_equal 200
    end
  end

  #test3
  describe 'Card validation' do
    it 'should return a JSON with validation results equal to true' do
      get '/api/v1/credit_card/validate?card_number=4565419325015023'
      results = JSON.parse(last_response.body)
      results['validated'].must_equal true
    end

  #test4
    it 'should return a JSON with validation results equal to false' do
      get '/api/v1/credit_card/validate?card_number=4565419325015022'
      results = JSON.parse(last_response.body)
      results['validated'].must_equal false
    end
  end

  #test5
  describe 'Store a card' do
    before do
      CreditCard.delete_all
    end

    it 'should save a card to the database' do
      req_header = {'CONTENT_TYPE'=>'application/json'}
      req_body = { card_number: "5192234226081802", expiration_date: "2017-04-19", owner: "Cheng-Yu Hsu", credit_network: "MasterCard" }
      post '/api/v1/credit_card', req_body.to_json, req_header
      last_response.status.must_equal 201
      saved_cc = CreditCard.first
      saved_cc.wont_be_nil
    end

    it 'should not save a card to the database' do
      req_header = {'CONTENT_TYPE'=>'application/json'}
      req_body = { card_number: "4565419325015022", expiration_date: "2017-04-19", owner: "Cheng-Yu Hsu", credit_network: "MasterCard" }
      post '/api/v1/credit_card', req_body.to_json, req_header
      last_response.status.must_equal 400
      saved_cc = CreditCard.first
      saved_cc.must_be_nil
    end

    it 'should encrypt the card number to the database' do
      req_header = {'CONTENT_TYPE'=>'application/json'}
      req_body = { card_number: "4565419325015023", expiration_date: "2017-04-19", owner: "Cheng-Yu Hsu", credit_network: "Visa" }
      post '/api/v1/credit_card', req_body.to_json, req_header
      saved_cc = CreditCard.first
      saved_cc.number.wont_equal saved_cc.encrypted_number
    end

  end

end
