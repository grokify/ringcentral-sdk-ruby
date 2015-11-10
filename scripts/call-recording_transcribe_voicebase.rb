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

# Set your credentials in the test credentials file

class RingCentralSdkBootstrap

  attr_reader :credentials

  def load_credentials(credentials_filepath, usage_string=nil)
    unless credentials_filepath.to_s.length>0
      raise usage_string.to_s
    end

    unless File.exists?(credentials_filepath.to_s)
      raise "Error: credentials file does not exist for: #{credentials_filepath}"
    end

    @credentials = MultiJson.decode(IO.read(credentials_filepath), :symbolize_keys=>true)
  end

end

boot = RingCentralSdkBootstrap.new
boot.load_credentials(ARGV.shift, 'Usage: call-recording_transcribe_voicebase.rb path/to/credentials.json')

module VoiceBase
  class Client
    def initialize(api_key, password)
      @api_key = api_key
      @password = password
      @transcript_type = 'machine'
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
  boot.credentials[:voicebase][:api_key],
  boot.credentials[:voicebase][:password])

upload_recordings(vbsdk, '.')

puts "DONE"
