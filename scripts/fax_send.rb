#!ruby

require 'dotenv'
require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

Dotenv.load ENV['ENV_PATH'] || '.env'

client = RingCentralSdk::REST::Client.new do |config|
  config.server_url = ENV['RINGCENTRAL_SERVER_URL']
  config.app_key    = ENV['RINGCENTRAL_CLIENT_ID']
  config.app_secret = ENV['RINGCENTRAL_CLIENT_SECRET']
  config.username   = ENV['RINGCENTRAL_USERNAME']
  config.extension  = ENV['RINGCENTRAL_EXTENSION']
  config.password   = ENV['RINGCENTRAL_PASSWORD']
end

res = client.messages.fax.create(
  to:            ENV['RINGCENTRAL_DEMO_FAX_TO'],
  coverPageText: ENV['RINGCENTRAL_DEMO_FAX_COVERPAGE_TEXT'],
  files:        [ENV['RINGCENTRAL_DEMO_FAX_FILE']]
)

pp res.body

puts 'DONE'