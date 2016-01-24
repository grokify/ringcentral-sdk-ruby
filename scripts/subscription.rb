#!ruby

require 'multi_json'
require 'ringcentral_sdk'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

config = RingCentralSdk::REST::Config.new.load_dotenv

client = RingCentralSdk::REST::Client.new
client.app_config(config.app)
client.authorize_user(config.user)

# An example observer object
class MyObserver
  def update(message)
    puts "Subscription Message Received"
    puts JSON.dump(message)
  end
end

def run_subscription(client)
  # Create an observable subscription and add your observer
  sub = client.create_subscription()
  sub.subscribe(["/restapi/v1.0/account/~/extension/~/presence"])

  sub.add_observer(MyObserver.new())

  puts "Click any key to finish"

  stop_script = gets

  # End the subscription
  sub.destroy()
end

run_subscription(client)

puts "DONE"