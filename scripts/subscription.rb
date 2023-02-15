#!ruby

require 'dotenv'
require 'multi_json'
require 'ringcentral_sdk'

env_path = ENV['ENV_PATH'] || './.env'
Dotenv.load(env_path) if File.exists?(env_path)

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.app_key       = ENV['RINGCENTRAL_CLIENT_ID']
  config.app_secret    = ENV['RINGCENTRAL_CLIENT_SECRET']
  config.server_url    = ENV['RINGCENTRAL_SERVER_URL']
  config.username      = ENV['RINGCENTRAL_USERNAME']
  config.extension     = ENV['RINGCENTRAL_EXTENSION']
  config.password      = ENV['RINGCENTRAL_PASSWORD']

  config.logger = Logger.new STDOUT
  config.logger.level = Logger::INFO
end

# An example observer object
class MyObserver
  def update(message)
    puts 'Subscription Message Received'
    puts JSON.dump(message)
  end
end

def run_subscription(client)
  client.config.logger.info('RUNNING_EXAMPLE_SUBSCRIPTION_SCRIPT')
  # Create an observable subscription and add your observer
  sub = client.create_subscription
  sub.subscribe(
    [
      '/restapi/v1.0/account/~/extension/~/message-store',
      '/restapi/v1.0/account/~/extension/~/presence'
    ]
  )

  sub.add_observer MyObserver.new

  puts 'Click any key to finish'

  gets

  # End the subscription
  sub.destroy
end

run_subscription client

puts 'DONE'
