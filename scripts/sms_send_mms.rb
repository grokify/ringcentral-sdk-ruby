#!ruby

require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.load_env = true
end

def send_mms_object client
  req = RingCentralSdk::REST::Request::SMS.new
  req.add_metadata({
    to: ENV['RC_DEMO_SMS_TO'],
    from: ENV['RC_DEMO_SMS_FROM'],
    text: ENV['RC_DEMO_SMS_TEXT']
  })
  req.add_file ENV['RC_DEMO_MMS_FILE']
  res = client.send_request req
end

def send_mms_quick client
  client.messages.sms.create(
    to: ENV['RC_DEMO_SMS_TO'],
    from: ENV['RC_DEMO_SMS_FROM'],
    text: ENV['RC_DEMO_SMS_TEXT'],
    media: ENV['RC_DEMO_MMS_FILE']
  )
end

res = send_mms_quick client

pp res.body
puts res.status

puts 'DONE'
