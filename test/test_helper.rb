require 'coveralls'
Coveralls.wear!

require 'test/unit'
require "mocha/test_unit"
require 'ringcentral_sdk'

rcsdk = RingCentralSdk::Sdk.new(
  'my_app_key',
  'my_app_secret',
  RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)