require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'mocha/test_unit'
require 'ringcentral_sdk'

RingCentralSdk::REST::Client.new do |config|
  config.app_key = 'my_app_key'
  config.app_secret = 'my_app_secret'
  config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
end
