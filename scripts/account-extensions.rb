#!ruby

require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

config = RingCentralSdk::REST::Config.new.load_dotenv

client = RingCentralSdk::REST::Client.new
client.app_config(config.app)
client.authorize_user(config.user)

extensions = RingCentralSdk::REST::Cache::Extensions.new client
extensions.retrieve_all

pp extensions.extensions_hash.keys

pp extensions.extensions_hash

puts "DONE"
