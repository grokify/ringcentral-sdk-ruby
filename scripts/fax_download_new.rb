#!ruby

require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.dotenv = true
end

# RcEventFaxDownloader is a helper class to download faxes
class RcEventFaxDownloader
  attr_accessor :event
  def initialize(client, posters = [], event_data = {})
    @client = client
    @posters = posters
    @event = RingCentralSdk::REST::Event.new event_data
    @retriever = RingCentralSdk::REST::MessagesRetriever.new @client
    @retriever.range = 0.5 # minutes
  end

  def download_fax
    puts @event.new_fax_count
    return unless @event.new_fax_count > 0
    messages = @retriever.retrieve_for_event @event, direction: 'Inbound', messageType: 'Fax'
    messages.each do |message|
      pp message
      message['attachments'].each do |att|
        url = att['uri']
        filename = 'fax_' + url.gsub(%r{^.*restapi/v[^/]+/}, '').gsub(%r{/}, '_')
        ext = att['contentType'] == 'application/pdf' ? '.pdf' : ''
        filename += ext
        response_file = @client.http.get url
        @posters.each { |poster| poster.write_file(filename, response_file) }
      end
    end
  end
end

# An observer object that uses RcDownloadNewFaxObserver to post
# to multiple chat posters
class RcDownloadNewFaxObserver
  def initialize(client, posters)
    @client = client
    @posters = posters
  end

  def update(message)
    puts 'DEMO_RECEIVED_NEW_MESSAGE'
    pp message
    event = RcEventFaxDownloader.new @client, @posters, message
    event.download_fax
    puts JSON.dump(message)
  end
end

# RcFaxPosterFilesystem is a helper class that writes files
# to the file system
class RcFaxPosterFilesystem
  def initialize(dir = '.')
    @dir = dir
  end

  def write_file(filename, response)
    filepath = File.join(@dir, filename)
    File.open(filepath, 'wb') { |fp| fp.write(response.body) }
  end
end

def run_subscription(client)
  # Create an observable subscription and add your observer
  sub = client.create_subscription
  sub.subscribe ['/restapi/v1.0/account/~/extension/~/message-store']

  # Create and add first chat poster
  posters = []
  posters.push RcFaxPosterFilesystem.new '.'

  # Add observer
  sub.add_observer RcDownloadNewFaxObserver.new client, posters

  # Run until key is clicked
  puts 'Click any key to finish'
  gets

  # End the subscription
  sub.destroy
end

run_subscription client

puts 'DONE'
