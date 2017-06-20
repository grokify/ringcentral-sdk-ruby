#!ruby

require 'sinatra'
require 'multi_json'
require 'ringcentral_sdk'

# Create and edit the .env file:
# $ cp config-sample.env.txt .env

client = RingCentralSdk::REST::Client.new do |config|
  config.load_env = true
end

set :logger, Logger.new(STDOUT)
set :port, ENV['MY_APP_PORT']

get '/' do
  token_json = client.token.nil? \
    ? '' : MultiJson.encode(client.token.to_hash, pretty: true)

  state = rand(1000000)
  logger.info("OAuth2 Callback Request State #{state}")

  erb :index, locals: {
    authorize_uri: client.authorize_url(state: state),
    redirect_uri: client.config.redirect_url,
    token_json: token_json}
end

get '/callback' do
  code = params.key?('code') ? params['code'] : ''
  state = params.key?('state') ? params['state'] : ''
  logger.info("OAuth2 Callback Response State #{state}")
  token = client.authorize_code(code) if code
  ''
end
