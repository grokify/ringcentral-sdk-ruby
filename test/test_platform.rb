require './test/test_helper.rb'

class RingCentralSdkPlatformTest < Test::Unit::TestCase
  def testSetup

    rcsdk = RingCentralSdk::Sdk.new(
      "my_app_key",
      "my_app_secret",
      RingCentralSdk::Sdk::RC_SERVER_SANDBOX
    )

    platform = rcsdk.platform
    assert_equal "bXlfYXBwX2tleTpteV9hcHBfc2VjcmV0", platform.send(:get_api_key)
    #assert_equal "Basic bXlfYXBwX2tleTpteV9hcHBfc2VjcmV0", platform.send(:get_auth_header)

    rcsdk = RingCentralSdk::Sdk.new(
      nil,
      nil,
      RingCentralSdk::Sdk::RC_SERVER_SANDBOX
    )

    url = rcsdk.platform.authorize_url({:redirect_uri => 'http://localhost:4567/oauth'})

    assert_equal 0, url.index(RingCentralSdk::Sdk::RC_SERVER_SANDBOX)

    token_data = {:access_token => 'test_token'}

    rcsdk.platform.set_token(token_data)

    assert_equal 'OAuth2::AccessToken', rcsdk.platform.token.class.name
    assert_equal 'Faraday::Connection', rcsdk.platform.client.class.name

    assert_raise do
      rcsdk.platform.request()
    end

    assert_raise do
      rcsdk.platform.set_token('test')
    end

    assert_equal '/restapi/v1.0/subscribe', rcsdk.platform.create_url('subscribe')
    assert_equal '/restapi/v1.0/subscribe', rcsdk.platform.create_url('/subscribe')
    assert_equal RingCentralSdk::Sdk::RC_SERVER_SANDBOX + '/restapi/v1.0/subscribe', rcsdk.platform.create_url('subscribe', true)

  end
end