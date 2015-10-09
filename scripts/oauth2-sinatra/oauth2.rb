#!ruby

require 'sinatra'
require 'multi_json'
require 'ringcentral_sdk'

# BEGIN CONFIG
# ENTER YOUR INFORMATION HERE
app_key      = 'my_app_key'
app_secret   = 'my_app_secret'
redirect_uri = 'http://localhost:4567/oauth'
# END CONFIG

rcsdk = RingCentralSdk::Sdk.new(
  app_key,
  app_secret,
  RingCentralSdk::Sdk::RC_SERVER_SANDBOX,
  {:redirect_uri => redirect_uri}
)

get '/' do
  erb :index, :locals => {
    :authorize_url => rcsdk.platform.authorize_url(),
    :redirect_uri  => redirect_uri
  }
end

get '/oauth' do
  code = params.has_key?('code') ? params['code'] : ''
  token_json = ''
  if code
    token = rcsdk.platform.authorize_code(code)
    token_json = MultiJson.encode(token.to_hash, :pretty=>true)
  end
  erb :oauth, :locals => {
    :code  => code,
    :token => token_json
  }
end