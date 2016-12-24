#!ruby

require 'ringcentral_sdk'
require 'pp'

require 'glip_poster'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.dotenv = true
end

# An SMS event poster. Takes a message store subscription
# event and posts inbound SMS as chats.
class RcEventSMSChatPoster
  attr_accessor :event
  def initialize(client, posters=[], event_data={})
    @client = client
    @posters = posters
    @event = RingCentralSdk::REST::Event.new event_data
    @retriever = RingCentralSdk::REST::MessagesRetriever.new @client
    @retriever.range = 0.5 # minutes
  end

  def post_message()
    return unless @event.new_sms_count > 0
    messages = @retriever.retrieve_for_event @event, direction: 'Inbound'
    messages.each do |message|
      post_message_to_chat message
    end
  end

  def post_message_to_chat(rec)
    text = 'SMS from ' + rec['from']['phoneNumber'] \
      + "\n* Time: " + rec['creationTime'] + "\n* Message: " + rec['subject']
    @posters.each { |v| v.send_message(text) }
  end
end

# An observer object that uses RcEventSMSChatPoster to post
# to multiple chat posters
class RcSmsToChatObserver
  def initialize(client, posters)
    @client = client
    @posters = posters
  end

  def update(message)
    @client.logger.info 'DEMO_RECEIVED_NEW_MESSAGE'
    event = RcEventSMSChatPoster.new @client, @posters, message
    event.post_message
    @client.logger.info JSON.dump(message)
  end
end

def new_glip
  glip = Glip::Poster.new ENV['RC_DEMO_GLIP_WEBHOOK_URL']
  glip.options[:icon] = ENV['RC_DEMO_GLIP_WEBHOOK_ICON']
  glip.options[:activity] = 'New Inbound SMS'

  body = "* event_filter: extension/message-store?messageType=SMS\n* actions: post SMS messages to Glip team"

  glip.send_message(body, {
    activity: 'RingCentral subscription initiated',
  })
  return glip
end

def run_subscription(client)
  # Create an observable subscription and add your observer
  sub = client.create_subscription
  sub.subscribe ['/restapi/v1.0/account/~/extension/~/message-store']

  # Create and add first chat poster
  posters = []
  posters.push new_glip()

  # Add observer
  sub.add_observer RcSmsToChatObserver.new client, posters

  # Run until key is clicked
  puts 'Click any key to finish'
  stop_script = gets

  # End the subscription
  sub.destroy
end

run_subscription client

puts 'DONE'
