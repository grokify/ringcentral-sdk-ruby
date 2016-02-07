#!ruby

require 'multi_json'
require 'ringcentral_sdk'
require 'voicebase'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

config = RingCentralSdk::REST::Config.new.load_dotenv

client = RingCentralSdk::REST::Client.new
client.app_config(config.app)
client.authorize_user(config.user)

def transcribe_recordings(rcsdk, vbsdk)
  # Retrieve voice call log records with recordings
  response = rcsdk.http.get do |req|
    params = {type: 'Voice', withRecording: 'True', dateFrom: '2015-01-01'}
    req.url 'account/~/extension/~/call-log', params
  end

  # Save recording and metadata for each call log record
  if response.body.has_key?('records')
    response.body['records'].each_with_index do |record,i|

      next unless record.has_key?('recording') &&
        record['recording'].has_key?('contentUri')

      content_uri = record['recording']['contentUri'].to_s

      content_uri += '?access_token=' + rcsdk.token.token.to_s

      response_vb = vbsdk.upload_media(mediaUrl: content_uri.to_s)

      pp response_vb.body
      
    end
  end
end

vbsdk = VoiceBase::V1::Client.new(
  config.env.data['RC_DEMO_VB_API_KEY'],
  config.env.data['RC_DEMO_VB_PASSWORD'])

transcribe_recordings(client, vbsdk)

puts "DONE"