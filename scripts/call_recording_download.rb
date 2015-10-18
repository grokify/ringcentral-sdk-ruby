#!ruby

require 'multi_json'
require 'ringcentral_sdk'

# Set your credentials in the test credentials file

credentials_file = ARGV.shift

unless credentials_file.to_s.length>0
  abort("Usage: call_recording_download.rb rc-credentials.json")
end

unless File.exists?(credentials_file.to_s)
  abort("Error: credentials file does not exist for: #{credentials_file}")
end

credentials = MultiJson.decode(IO.read(credentials_file))

rcsdk = RingCentralSdk.new(
  credentials['app_key'],
  credentials['app_secret'],
  credentials['server']
)

rcsdk.authorize(
  credentials['username'],
  credentials['extension'],
  credentials['password']
)

# Retrieve voice call log records with recordings
response = rcsdk.client.get do |req|
  params = {:type => 'Voice', :withRecording => 'True',:dateFrom=>'2015-01-01'}
  req.url 'account/~/extension/~/call-log', params
end

# Save recording and metadata for each call log record
if response.body.has_key?('records')
  response.body['records'].each do |record|
    # Retrieve call recording

    unless record.has_key?('recording') && record['recording'].has_key?('contentUri')
      next
    end

    response_file = rcsdk.client.get do |req|
      req.url record['recording']['contentUri']
    end

    # Save call recording
    ext = response_file.headers['Content-Type'].to_s == 'audio/mpeg' \
      ? '.mp3' : '.wav'

    file_mp3 = 'recording_' + record['id'] + ext
    File.open(file_mp3, 'wb') { |fp| fp.write(response_file.body) }

    # Save call log record (call recording metadata) using 'json'
    file_meta = 'recording_' + record['id'] + '.json'
    File.open(file_meta, 'wb') { |fp| fp.write(record.to_json) }
  end
end

puts "DONE"