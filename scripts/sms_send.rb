#!ruby

require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.dotenv = true
end

res = client.messages.sms.create(
  from: ENV['RC_DEMO_SMS_FROM'],
  to: ENV['RC_DEMO_SMS_TO'],
  text: ENV['RC_DEMO_SMS_TEXT']
)

pp res.body

puts "DONE"
