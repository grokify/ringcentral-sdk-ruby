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

  end
end