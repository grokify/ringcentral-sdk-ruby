#!ruby

require 'ringcentral_sdk'
require 'pp'

# Set your credentials in the .env file
# Use the credentials_sample.env.txt file as a scaffold

client = RingCentralSdk::REST::Client.new do |config|
  config.load_env = true
end

extensions = RingCentralSdk::REST::Cache::Extensions.new client
extensions.retrieve_all

pp extensions.extensions_hash.keys

pp extensions.extensions_hash

puts 'DONE'
