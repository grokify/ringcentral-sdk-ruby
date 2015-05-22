require './test/test_helper.rb'

class RingCentralSdkHelperRequestTest < Test::Unit::TestCase
  def testSetup

    req = RingCentralSdk::Helpers::Request.new

    assert_equal 'get', req.method()
    assert_equal '', req.url()
    assert_equal '', req.content_type()
    assert_equal '', req.body()

  end
end