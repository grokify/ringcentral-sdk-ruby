#!ruby

require 'multi_json'
require 'ringcentral_sdk'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.dotenv = true
end

# An example observer object
class MyObserver
  def update(message)
    puts 'Subscription Message Received'
    puts JSON.dump(message)
  end
end

def run_subscription(client)
  # Create an observable subscription and add your observer
  sub = client.create_subscription
  sub.subscribe([
    '/restapi/v1.0/account/~/extension/~/message-store/instant?type=SMS'
  ])

  sub.add_observer MyObserver.new

  puts 'Click any key to finish'

  stop_script = gets

  # End the subscription
  sub.destroy
end

run_subscription client

puts 'DONE'
