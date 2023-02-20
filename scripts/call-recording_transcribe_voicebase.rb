#!ruby

require 'date'
require 'faraday'
require 'faraday_middleware'
require 'multi_json'
require 'ringcentral_sdk'
require 'voicebase'
require 'pp'

# This demo uploads MP3 recording files with the file format "recording_.*\.mp3"
# to VoiceBase for text transcription. This is the file format used by the
# call-recording_download.rb script.
#
# This file uses a Ruby port of the PHP demo in the VoiceBase API Developers
# Guide version 1.1.4 PDF page 18.
#
# Set your credentials in the .env file
# Use the credentials_sample.env.txt file as a scaffold

def upload_recordings(vbsdk, dir)
  filepath = File.join(dir, 'recording_*.mp3')
  Dir.glob(filepath).each_with_index do |file, _i|
    puts file
    res = vbsdk.upload_media(filePath: file, fileContentType: 'audio/mpeg', desc: 'myfile')
    pp res.body
    puts res.status
  end
end

vbsdk = VoiceBase::V1::Client.new(
  ENV['RINGCENTRAL_DEMO_VB_API_KEY'],
  ENV['RINGCENTRAL_DEMO_VB_PASSWORD']
)

upload_recordings(vbsdk, '.')

puts 'DONE'
