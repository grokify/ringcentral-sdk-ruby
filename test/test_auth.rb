require './test/test_helper.rb'

class RingCentralSdkAuthTest < Test::Unit::TestCase
  def testSetup

    auth = RingCentralSdk::Platform::Auth.new

    assert_equal false, auth.is_access_token_valid()
    assert_equal false, auth.set_data(nil)
    assert_equal true, auth.set_data({'expire_time' => Time.now.to_i + 86400, 'token_type' => 'Bearer' })
    assert_equal 'Bearer', auth.token_type
    assert_equal true, auth.is_access_token_valid()

  end
end