require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'mocha/test_unit'
require 'ringcentral_sdk'

client = RingCentralSdk.new(
  'my_app_key',
  'my_app_secret',
  RingCentralSdk::RC_SERVER_SANDBOX
)
