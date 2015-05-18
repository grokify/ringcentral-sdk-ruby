require 'test/unit'
require 'ringcentral_sdk'
require 'coveralls'
Coveralls.wear!

rcsdk = RingCentralSdk::Sdk.new(
  "myAppKey",
  "myAppSecret",
  RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)