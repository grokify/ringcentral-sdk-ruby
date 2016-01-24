#!ruby

require 'date'
require 'faraday'
require 'faraday_middleware'
require 'multi_json'
require 'ringcentral_sdk'
require 'pp'

=begin
  
This demo uploads MP3 recording files with the file format "recording_.*\.mp3"
to VoiceBase for text transcription. This is the file format used by the
call-recording_download.rb script.

This file uses a Ruby port of the PHP demo in the VoiceBase API Developers
Guide version 1.1.4 PDF page 18.

=end

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

config = RingCentralSdk::REST::Config.new.load_dotenv

client = RingCentralSdk::REST::Client.new(
  config.app.key,
  config.app.secret,
  config.app.server_url,
  {
    :username => config.user.username,
    :extension => config.user.extension,
    :password => config.user.password
  }
)

module VoiceBase
  class Client
    def initialize(api_key, password, transcript_type='machine-best')
      @api_key = api_key
      @password = password
      @transcript_type = transcript_type
      @conn = Faraday.new(:url => 'https://api.voicebase.com/services') do |faraday|
        faraday.request  :multipart               # multipart/form-data
        faraday.response :json
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    def upload_media(filepath, content_type)
      params = {
        :version        => '1.1',
        :apikey         => @api_key,
        :password       => @password,
        :action         => 'uploadMedia',
        :file           => Faraday::UploadIO.new(filepath, content_type),
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
      response = @conn.post '/services', params
      pp response
      puts response.body['fileUrl']
    end
  end
end

def upload_recordings(vbsdk, dir)
  Dir.glob('recording_*.mp3').each_with_index do |file,i|
    puts file
    vbsdk.upload_media(file, 'audio/mpeg')
    break
  end
end

vbsdk = VoiceBase::Client.new(
  config.env.data['RC_DEMO_VB_API_KEY'],
  config.env.data['RC_DEMO_VB_PASSWORD'])

upload_recordings(vbsdk, '.')

puts "DONE"
