require './test/test_helper.rb'

class RingCentralSdkPubnubTest < Test::Unit::TestCase
  def testSetup

    rcsdk = RingCentralSdk::Sdk.new(
      'myAppKey',
      'myAppSecret',
      RingCentralSdk::Sdk::RC_SERVER_SANDBOX
    )

    pubnub_factory = RingCentralSdk::PubnubFactory.new()
    assert_equal 'RingCentralSdk::PubnubFactory', pubnub_factory.class.name

    pubnub = pubnub_factory.pubnub('', '', nil)
    assert_equal 'Pubnub::Client', pubnub.class.name

    sub = rcsdk.create_subscription()
    assert_equal "RingCentralSdk::Subscription", sub.class.name

    pubnub_factory2 = RingCentralSdk::PubnubFactory.new(true)
    assert_raise do
      pubnub_factory2.pubnub('', '', nil)
    end

  end
end