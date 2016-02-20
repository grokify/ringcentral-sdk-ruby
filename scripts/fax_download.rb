#!ruby

require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

config = RingCentralSdk::REST::Config.new.load_dotenv

client = RingCentralSdk::REST::Client.new
client.app_config = config.app
client.authorize_user config.user

puts RingCentralSdk::VERSION

req = RingCentralSdk::REST::Request::Simple.new(
  method: 'get',
  url: 'account/~/extension/~/message-store',
  params: {
    direction: 'Inbound',
    messageType: 'Fax'
  }
)

res = client.send_request(req)
  
pp res.body

puts "---"

res.body['records'].each do |rec|
  rec['attachments'].each do |att|
    pp att
    url = att['uri']
    filename = 'fax2_' + url.gsub(%r{^.*restapi/v[^/]+/}, '').gsub(%r{/},'_')
    ext = att['contentType'] == 'application/pdf' ? '.pdf' : ''
    filename += ext
    puts filename

    response_file = client.http.get url
    File.open(filename, 'wb') { |fp| fp.write(response_file.body) }
  end
end

puts "DONE"
