#!ruby

require 'multi_json'
require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

config = RingCentralSdk::REST::Config.new.load_dotenv

client = RingCentralSdk::REST::Client.new
client.app_config(config.app)
client.authorize_user(config.user)

module VoiceBase
  class Client
    def initialize(api_key, password, transcript_type='machine-best')
      @api_key = api_key
      @password = password
      @transcript_type = transcript_type
      @conn = Faraday.new(:url => 'https://api.voicebase.com/services') do |faraday|
        faraday.request  :url_encoded             # multipart/form-data
        faraday.response :json
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    def upload_media(opts={})
      params = {
        :version        => '1.1',
        :apikey         => @api_key,
        :password       => @password,
        :action         => 'uploadMedia',
        :title          => DateTime.now.strftime('%Y-%m-%d %I:%M:%S %p'),
        :transcriptType => @transcript_type,
        :desc           => 'file description',
        :recordedDate   => DateTime.now.strftime('%Y-%m-%d %I:%M:%S'),
        :collection     => '',
        :public         => false,
        :sourceUrl      => '',
        :lang           => 'en',
        :imageUrl       => ''
      }
      if opts.has_key?(:filepath) && opts.has_key?(:content_type)
        params[:file] = Faraday::UploadIO.new(filepath, content_type)
      elsif opts.has_key?(:mediaUrl)
        params[:mediaUrl] = opts[:mediaUrl]
      else
        raise "Neither file or mediaUrl have been set"
      end
      response = @conn.post '/services', params
      pp response
      puts response.body['fileUrl']
      return response
    end
  end
end

def transcribe_recordings(rcsdk, vbsdk)
  # Retrieve voice call log records with recordings
  response = rcsdk.http.get do |req|
    params = {:type => 'Voice', :withRecording => 'True',:dateFrom=>'2015-01-01'}
    req.url 'account/~/extension/~/call-log', params
  end

  # Save recording and metadata for each call log record
  if response.body.has_key?('records')
    response.body['records'].each_with_index do |record,i|

      next unless record.has_key?('recording') &&
        record['recording'].has_key?('contentUri')

      content_uri = record['recording']['contentUri'].to_s

      content_uri += '?access_token=' + rcsdk.token.token.to_s

      response_vb = vbsdk.upload_media({:mediaUrl => content_uri.to_s})

      pp(response_vb.body)
      
    end
  end
end

vbsdk = VoiceBase::Client.new(
  config.env.data['RC_DEMO_VB_API_KEY'],
  config.env.data['RC_DEMO_VB_PASSWORD'])

transcribe_recordings(client, vbsdk)

puts "DONE"