#!ruby

require 'dotenv'
require 'ringcentral_sdk'
require 'pp'

envPath = ENV['ENV_PATH'] || '.env'
Dotenv.load envPath

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

#client = RingCentralSdk::REST::Client.new do |config|
#  config.load_env = true
#end

def EnvVal(envVar)
  #envVar = envVar + '_2'
  ENV[envVar]
end

client = RingCentralSdk::REST::Client.new do |config|
  config.server_url = EnvVal('RINGCENTRAL_SERVER_URL')
  config.app_key    = EnvVal('RINGCENTRAL_CLIENT_ID')
  config.app_secret = EnvVal('RINGCENTRAL_CLIENT_SECRET')
  config.username   = EnvVal('RINGCENTRAL_USERNAME')
  config.extension  = EnvVal('RINGCENTRAL_EXTENSION')
  config.password   = EnvVal('RINGCENTRAL_PASSWORD')
end

def handleResponse(res)
  puts res.status
  pp res.body
end

def ringout(client, accountId, extensionId, to, from, callerId)
  body = {
    to:       { phoneNumber: to },
    from:     { phoneNumber: from },
    callerId: { phoneNumber: callerId },
    playPrompt: false
  }
  client.http.post do |req|
    req.url "account/#{accountId}/extension/#{extensionId}/ring-out"
    req.headers['Content-Type'] = 'application/json'
    req.body = body
  end
end

handleResponse ringout(client, '~', '~', '+14155550100', '+16505550100', '+16505550100')
