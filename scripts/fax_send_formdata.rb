#!ruby

require 'ringcentral_sdk'
require 'pp'
require 'mime/types'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.load_env = true
end

res = client.http.post do |req|
  req.url 'account/~/extension/~/fax'
  filepath = ENV['RC_DEMO_FAX_FILE']
  ct = MIME::Types.type_for(filepath).first.content_type \
    || 'application/octet-stream'
  req.body = {
    to: ENV['RC_DEMO_FAX_TO'],
    coverPageText: 'Ruby REST Client Formdata',
    attachment: Faraday::UploadIO.new(filepath, ct)
  }
end

pp res.body

puts 'DONE'
