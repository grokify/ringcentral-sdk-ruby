#!ruby

require 'dotenv'
require 'ringcentral_sdk'
require 'pp'

Dotenv.load ENV['ENV_PATH'] || '.env'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.server_url = ENV['RINGCENTRAL_SERVER_URL']
  config.app_key    = ENV['RINGCENTRAL_CLIENT_ID']
  config.app_secret = ENV['RINGCENTRAL_CLIENT_SECRET']
  config.username   = ENV['RINGCENTRAL_USERNAME']
  config.extension  = ENV['RINGCENTRAL_EXTENSION']
  config.password   = ENV['RINGCENTRAL_PASSWORD']
end

def ringout(client, accountId, extensionId, to, from, callerId,playPrompt)
  body = {
    to:       { phoneNumber: to },
    from:     { phoneNumber: from },
    callerId: { phoneNumber: callerId },
    playPrompt: playPrompt,
    country: {id: 1}
  }
  client.http.post do |req|
    req.url "account/#{accountId}/extension/#{extensionId}/ring-out"
    req.headers['Content-Type'] = 'application/json'
    req.body = body
  end
end

res = ringout(client, '~', '~', 
  ENV['RINGCENTRAL_DEMO_RINGOUT_TO'],
  ENV['RINGCENTRAL_DEMO_RINGOUT_FROM'],
  ENV['RINGCENTRAL_DEMO_RINGOUT_FROM'],
  ENV['RINGCENTRAL_DEMO_RINGOUT_PROMPT'])

puts res.status
pp res.body

puts 'DONE'