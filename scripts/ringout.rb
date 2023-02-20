#!ruby

require 'dotenv'
require 'multi_json'
require 'ringcentral_sdk'
require 'pp'

Dotenv.load ENV['ENV_PATH'] || '.env'

# Set your credentials in the .env file
# Use the credentials_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.server_url    = ENV['RINGCENTRAL_SERVER_URL']
  config.client_id     = ENV['RINGCENTRAL_CLIENT_ID']
  config.client_secret = ENV['RINGCENTRAL_CLIENT_SECRET']
  config.username      = ENV['RINGCENTRAL_USERNAME']
  config.extension     = ENV['RINGCENTRAL_EXTENSION']
  config.password      = ENV['RINGCENTRAL_PASSWORD']
end

def ringout(client, accountId, extensionId, to, from, callerId,playPrompt)
  body = {
    to:       { phoneNumber: to },
    from:     { phoneNumber: from },
    callerId: { phoneNumber: callerId },
    playPrompt: playPrompt,
    country: {id: 1}
  }

  puts MultiJson.encode body, pretty: true

  client.http.post do |req|
    req.url "/restapi/v1.0/account/#{accountId}/extension/#{extensionId}/ring-out"
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

puts MultiJson.encode res.body, pretty: true

puts 'DONE'