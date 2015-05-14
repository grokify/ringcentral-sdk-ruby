#!ruby

require 'ringcentral_sdk'

# Set Correctly

rc_server  = RingCentralSdk::Sdk::RC_SERVER_SANDBOX

app_key    = 'my_app_key'
app_secret = 'my_app_secret'
username   = 'my_username'
extension  = nil
password   = 'my_password'

file_name  = '/path/to/my_file.pdf'

# No need to edit below

rcsdk = RingCentralSdk::Sdk.new(
  app_key,
  app_secret,
  rc_server
)
platform = rcsdk.platform

platform.authorize(username,extension,password)

fax = RingCentralSdk::Helpers::CreateFaxRequest.new(
  nil,
  {
  	:to            => [{:phoneNumber => 6505551212}],
  	:faxResolution => 'High',
  	:coverPageText => 'RingCentral Fax Base64 using Ruby!'
  },
  :file_name       => file_name,
  :base64_encode   => true
)

puts fax.body

client = rcsdk.platform.client

if 1==1
  response = client.post do |req|
    req.url fax.url
    req.headers['Content-Type'] = fax.content_type
    req.body = fax.body
  end
  puts response.body.to_s
end

puts "DONE"