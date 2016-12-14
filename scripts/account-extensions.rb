#!ruby

require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.dotenv = true
end

extensions = RingCentralSdk::REST::Cache::Extensions.new client
extensions.retrieve_all

pp extensions.extensions_hash.keys

pp extensions.extensions_hash

puts "DONE"
