#!ruby

require 'multi_json'
require 'ringcentral_sdk'

# Set your credentials in the test credentials file

class RingCentralSdkBootstrap

  def load_credentials(credentials_filepath, usage_string=nil)
    unless credentials_filepath.to_s.length>0
      raise usage_string.to_s
    end

    unless File.exists?(credentials_filepath.to_s)
      raise "Error: credentials file does not exist for: #{credentials_filepath}"
    end

    @credentials = MultiJson.decode(IO.read(credentials_filepath), :symbolize_keys=>true)
  end

  def get_sdk_with_token(env=:sandbox, app_index=0, resource_owner_index=0)
    credentials = @credentials

    rcsdk = RingCentralSdk.new(
      credentials[env][:applications][app_index][:app_key],
      credentials[env][:applications][app_index][:app_secret],
      credentials[env][:api][:server]
    )

    rcsdk.authorize(
      credentials[env][:resource_owners][resource_owner_index][:username],
      credentials[env][:resource_owners][resource_owner_index][:extension],
      credentials[env][:resource_owners][resource_owner_index][:password],
    ) 

    return rcsdk
  end

end

boot = RingCentralSdkBootstrap.new
boot.load_credentials(ARGV.shift, 'Usage: call_recording_download.rb path/to/credentials.json')
rcsdk = boot.get_sdk_with_token()

def get_recordings(rcsdk)
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
end

get_recordings(rcsdk)

puts "DONE"