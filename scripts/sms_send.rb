#!ruby

require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

config = RingCentralSdk::REST::Config.new.load_dotenv

client = RingCentralSdk::REST::Client.new
client.app_config = config.app
client.authorize_user config.user

res = client.messages.sms.create(
  from: config.env.data['RC_DEMO_SMS_FROM'],
  to: config.env.data['RC_DEMO_SMS_TO'],
  text: config.env.data['RC_DEMO_SMS_TEXT']
)

pp res.body

puts "DONE"
