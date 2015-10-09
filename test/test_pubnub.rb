require './test/test_helper.rb'

class RingCentralSdkPubnubTest < Test::Unit::TestCase
  def testSetup

    rcsdk = RingCentralSdk::Sdk.new(
      "myAppKey",
      "myAppSecret",
      RingCentralSdk::Sdk::RC_SERVER_SANDBOX
    )

    sub = rcsdk.create_subscription()

    assert_equal "RingCentralSdk::Subscription", sub.class.name

  end
end