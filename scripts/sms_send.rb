#!ruby

require 'dotenv'
require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

envPath = ENV['ENV_PATH'] || '.env'
Dotenv.load envPath

client = RingCentralSdk::REST::Client.new do |config|
  config.server_url = ENV['RINGCENTRAL_SERVER_URL']
  config.app_key    = ENV['RINGCENTRAL_CLIENT_ID']
  config.app_secret = ENV['RINGCENTRAL_CLIENT_SECRET']
  config.username   = ENV['RINGCENTRAL_USERNAME']
  config.extension  = ENV['RINGCENTRAL_EXTENSION']
  config.password   = ENV['RINGCENTRAL_PASSWORD']
end


res = client.messages.sms.create(
  from: ENV['RINGCENTRAL_DEMO_SMS_FROM'],
  to:   ENV['RINGCENTRAL_DEMO_SMS_TO'],
  text: ENV['RINGCENTRAL_DEMO_SMS_TEXT']
)

pp res.body
pp res.status

puts 'DONE'
