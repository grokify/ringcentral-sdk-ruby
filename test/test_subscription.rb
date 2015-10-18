require './test/test_helper.rb'

class RingCentralSdkSubscriptionTest < Test::Unit::TestCase
  def setup
    @rcsdk = RingCentralSdk::Sdk.new(
      'myAppKey',
      'myAppSecret',
      RingCentralSdk::Sdk::RC_SERVER_SANDBOX
    )
  end

  def test_main
    sub = @rcsdk.create_subscription()
    assert_equal "RingCentralSdk::Subscription", sub.class.name

    assert_equal 0, sub.event_filters.length

    sub.add_events(['/restapi/v1.0/account/~/extension/~/message-store'])
    assert_equal 1, sub.event_filters.length

    sub.add_events(['/restapi/v1.0/account/~/extension/~/presence'])
    assert_equal 2, sub.event_filters.length
    
    sub.set_events(['/restapi/v1.0/account/~/extension/~/presence'])
    assert_equal 1, sub.event_filters.length

    assert_equal false, sub.alive?

    assert_raise do
      sub.add_events(nil)
    end

    assert_raise do
      sub.set_events(nil)
    end

    assert_raise do
      sub.subscribe(nil)
    end

    assert_raise do
      sub.renew(nil)
    end

    sub.set_events([])
    
    assert_raise do
      sub.subscribe()
    end

    assert_raise do
      sub.renew()
    end   

    # sub.subscribe(['/restapi/v1.0/account/~/extension/~/presence'])

    sub_data = sub.subscription()
    assert_equal sub_data['deliveryMode']['transportType'], 'PubNub'
    assert_equal sub_data['deliveryMode']['encryption'], false
    sub_data['deliveryMode']['encryption'] = true
    sub.set_subscription(sub_data)
    sub_data = sub.subscription()
    assert_equal sub_data['deliveryMode']['encryption'], true

    assert_equal nil, sub.pubnub()

    sub.destroy()
    sub_data = sub.subscription()
    assert_equal sub_data['deliveryMode']['encryption'], false

  end
end