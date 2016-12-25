#!ruby

require 'multi_json'
require 'pp'
require 'ringcentral_sdk'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.dotenv = true
end

# Create an array of event_filters from the array of extensions
def get_event_filters_for_extensions(extension_ids, account_id = '~')
  event_filters = []

  extension_ids.each do |extension_id|
    if extension_id
      event_filter =
        '/restapi/v1.0/account/#{account_id}/extension/#{extension_id}' +
        '/presence?detailedTelephonyState=true'
      event_filters.push event_filter
    end
  end
  event_filters
end

# An example observer object
class MyObserver
  def update(message)
    puts "Subscription Message Received"
    puts JSON.dump(message)
  end
end

def run_subscription(client, event_filters)
  # Create an observable subscription and add your observer
  sub = client.create_subscription
  res = sub.subscribe(event_filters)

  pp(res)

  # Add observer
  sub.add_observer MyObserver.new()

  # Run until user clicks key to finish
  puts "Click any key to finish"
  stop_script = gets

  # End the subscription
  sub.destroy
end

# Get all extensions
extensions = RingCentralSdk::REST::Cache::Extensions.new client
extensions.retrieve_all

# Get event filters for extensions
event_filters = get_event_filters_for_extensions(extensions.extensions_hash.keys)

# Make a subscription for all event_filters
run_subscription(client, event_filters)

puts 'DONE'
