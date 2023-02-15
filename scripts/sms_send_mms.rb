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

def send_mms_object(client)
  req = RingCentralSdk::REST::Request::Multipart.new(
    method: 'post',
    url: '/restapi/v1.0/account/~/extension/~/sms'
  ).
  add_json({
    to:   [{phoneNumber: ENV['RINGCENTRAL_DEMO_SMS_TO']}],
    from: {phoneNumber: ENV['RINGCENTRAL_DEMO_SMS_FROM']},
    text: ENV['RINGCENTRAL_DEMO_SMS_TEXT']
  }).
  add_file(ENV['RINGCENTRAL_DEMO_MMS_FILE'])
  res = client.send_request req
end

def send_mms_quick(client)
  client.messages.sms.create(
    to:    [ENV['RINGCENTRAL_DEMO_SMS_TO']],
    from:  ENV['RINGCENTRAL_DEMO_SMS_FROM'],
    text:  ENV['RINGCENTRAL_DEMO_SMS_TEXT'],
    media: ENV['RINGCENTRAL_DEMO_MMS_FILE']
  )
end

pp({    to:   [ENV['RINGCENTRAL_DEMO_SMS_TO']],    from: ENV['RINGCENTRAL_DEMO_SMS_FROM'],    text: ENV['RINGCENTRAL_DEMO_SMS_TEXT']  })

res = send_mms_object client

pp res.body
puts res.status

puts 'DONE'
