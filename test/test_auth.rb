require './test/test_helper.rb'

class RingCentralSdkAuthTest < Test::Unit::TestCase
  def testSetup

    rcsdk = RingCentralSdk::Sdk.new(
      "my_app_key",
      "my_app_secret",
      RingCentralSdk::Sdk::RC_SERVER_SANDBOX
    )

    auth = RingCentralSdk::Platform::Auth.new

    assert_equal false, auth.is_access_token_valid()
    assert_equal false, auth.set_data(nil)
    assert_equal true, auth.set_data({"expire_time" => Time.now.to_i + 86400 })
    assert_equal true, auth.is_access_token_valid()

  end
end