#!ruby

require 'sinatra'
require 'multi_json'
require 'ringcentral_sdk'

# Enter config in .env file

client = RingCentralSdk::REST::Client.new
config = RingCentralSdk::REST::Config.new.load_dotenv
client.app_config(config.app)

get '/' do
  erb :index, :locals => {
    :authorize_url => client.authorize_url(),
    :redirect_uri  => config.app.redirect_url
  }
end

get '/oauth' do
  code = params.key?('code') ? params['code'] : ''
  token_json = ''
  if code
    token = client.authorize_code(code)
    token_json = MultiJson.encode(token.to_hash, :pretty=>true)
  end
  erb :oauth, :locals => {
    :code  => code,
    :token => token_json
  }
end
