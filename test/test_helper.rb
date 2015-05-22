require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'ringcentral_sdk'

rcsdk = RingCentralSdk::Sdk.new(
  "myAppKey",
  "myAppSecret",
  RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)