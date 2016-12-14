#!ruby

require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.dotenv = true
end

res = client.messages.fax.create(
  to: ENV['RC_DEMO_FAX_TO'],
  coverPageText: ENV['RC_DEMO_FAX_COVERPAGE_TEXT'],
  files: [ENV['RC_DEMO_FAX_FILE']]
)

pp res.body

puts "DONE"
