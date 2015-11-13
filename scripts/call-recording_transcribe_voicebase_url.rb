#!ruby

require 'multi_json'
require 'ringcentral_sdk'
require 'pp'

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

  def get_sdk_with_token(env=:sandbox, app_index=0, resource_owner_index=0)
    credentials = @credentials

    app_index = 0 unless app_index
    resource_owner_index = 0 unless resource_owner_index

    if app_index.to_s =~ /^[0-9]+$/
      app_index = app_index.to_i if app_index.is_a?(String)
    else
      app_index = 0
    end

    if resource_owner_index.to_s =~ /^[0-9]+$/
      resource_owner_index = resource_owner_index.to_i if resource_owner_index.is_a?(String)
    else
      resource_owner_index = 0
    end

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
boot.load_credentials(ARGV.shift, 'Usage: call-recording_download.rb path/to/credentials.json')
rcsdk = boot.get_sdk_with_token(:sandbox, ARGV.shift, ARGV.shift)

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
  response = rcsdk.client.get do |req|
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
  boot.credentials[:voicebase][:api_key],
  boot.credentials[:voicebase][:password])

transcribe_recordings(rcsdk, vbsdk)

puts "DONE"