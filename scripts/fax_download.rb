#!ruby

require 'dotenv'
require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

envPath = ENV['ENV_PATH'] || '.env'
puts envPath
Dotenv.load envPath

def EnvVal(envVar)
  #envVar = envVar + '_2'
  ENV[envVar]
end

client = RingCentralSdk::REST::Client.new do |config|
  config.server_url = EnvVal('RINGCENTRAL_SERVER_URL')
  config.app_key    = EnvVal('RINGCENTRAL_CLIENT_ID')
  config.app_secret = EnvVal('RINGCENTRAL_CLIENT_SECRET')
  config.username   = EnvVal('RINGCENTRAL_USERNAME')
  config.extension  = EnvVal('RINGCENTRAL_EXTENSION')
  config.password   = EnvVal('RINGCENTRAL_PASSWORD')
end
puts RingCentralSdk::VERSION

req = RingCentralSdk::REST::Request::Simple.new(
  method: 'get',
  url: 'account/~/extension/~/message-store',
  params: {
    direction:   'Outbound',
    messageType: 'Fax',
    dateFrom:    '2015-01-01T00:00:00Z'
  }
)

res = client.send_request req

pp res.body

puts '---'

if 1==0

res.body['records'].each do |rec|
  rec['attachments'].each do |att|
    pp att
    url = att['uri']
    filename = '_fax2_' + url.gsub(%r{^.*restapi/v[^/]+/}, '').gsub(%r{/}, '_')
    ext = att['contentType'] == 'application/pdf' ? '.pdf' :
      att['contentType'] == 'image/tiff' ? '.tiff' : ''
    filename += ext
    puts filename

    response_file = client.http.get url
    File.open(filename, 'wb') { |fp| fp.write(response_file.body) }
  end
end
end
puts 'DONE'
