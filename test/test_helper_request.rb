require './test/test_base.rb'

class RingCentralSdkHelperRequestTest < Test::Unit::TestCase
  def testSetup

    req = RingCentralSdk::REST::Request::Base.new

    assert_equal 'get', req.method()
    assert_equal '', req.url()
    assert_equal '', req.content_type()
    assert_equal '', req.body()

  end
end