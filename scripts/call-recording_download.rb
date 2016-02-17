#!ruby

require 'multi_json'
require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

config = RingCentralSdk::REST::Config.new.load_dotenv

client = RingCentralSdk::REST::Client.new
client.app_config config.app
client.authorize_user config.user

def get_recordings(client)
  # Retrieve voice call log records with recordings
  response = client.http.get do |req|
    params = {type: 'Voice', withRecording: 'True', dateFrom: '2015-01-01'}
    req.url 'account/~/extension/~/call-log', params
  end

  # Save recording and metadata for each call log record
  if response.body.key?('records')
    response.body['records'].each_with_index do |record, i|
      # Retrieve call recording

      unless record.key?('recording') && record['recording'].key?('contentUri')
        next
      end

      response_file = client.http.get do |req|
        req.url record['recording']['contentUri']
      end

      # If throttled
      if response_file.status.to_i == 429
        # Sleep for Retry-After seconds
        sleep(response_file.headers['Retry-After'].to_i)

        # Retry recording
        response_file = client.http.get do |req|
          req.url record['recording']['contentUri']
        end
      end
      
      # Save call recording
      ext = response_file.headers['Content-Type'].to_s == 'audio/mpeg' \
        ? '.mp3' : '.wav'

      file_mp3 = 'recording_' + record['id'] + '_' + record['recording']['id'] + ext
      File.open(file_mp3, 'wb') { |fp| fp.write(response_file.body) }

      # Save call log record (call recording metadata) using 'json'
      file_meta = 'recording_' + record['id'] + '_' + record['recording']['id'] + '.json'
      File.open(file_meta, 'wb') { |fp| fp.write(record.to_json) }
    end
  end
end

get_recordings(client)

puts "DONE"