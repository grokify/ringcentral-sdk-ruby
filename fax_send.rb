#!ruby

require 'multi_json'
require 'ringcentral_sdk'

credentials_file = ARGV.shift

unless credentials_file.to_s.length>0
  abort("Usage: fax_send.rb rc-credentials.json phone_number my_file.pdf")
end

unless File.exists?(credentials_file.to_s)
  abort("Error: credentials file does not exist for: #{credentials_file}")
end

credentials = MultiJson.decode(IO.read(credentials_file))

to_phone_number = ARGV.shift

unless to_phone_number.to_s.length>0
  abort("Usage: fax_send.rb rc-credentials.json phone_number my_file.pdf")
end

file_name = ARGV.shift

unless file_name.to_s.length>0
  abort("Usage: fax_send.rb rc-credentials.json phone_number my_file.pdf")
end

unless File.exists?(file_name.to_s)
  abort("Error: file to fax does not exist for: #{file_name}")
end

rcsdk = RingCentralSdk.new(
  credentials['app_key'],
  credentials['app_secret'],
  credentials['server']
)

rcsdk.platform.authorize(
  credentials['username'],
  credentials['extension'],
  credentials['password']
)

fax = RingCentralSdk::Helpers::CreateFaxRequest.new(
  nil,
  {
  	:to            => [{:phoneNumber => to_phone_number}],
  	:faxResolution => 'High',
  	:coverPageText => 'RingCentral Fax Base64 using Ruby!'
  },
  :file_name       => file_name,
  :base64_encode   => true
)

puts fax.body

client = rcsdk.client

if 1==1
  response = client.post do |req|
    req.url fax.url
    req.headers['Content-Type'] = fax.content_type
    req.body = fax.body
  end
  puts response.body.to_s
end

puts "DONE"