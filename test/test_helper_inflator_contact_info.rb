require './test/test_base.rb'

class RingCentralSdkHelperInflatorContactInfoTest < Test::Unit::TestCase
  def testSetup

    inf  = RingCentralSdk::REST::Request::Inflator::ContactInfo.new

    arr1 = inf.inflate_to_array(16505551212)
    assert_equal 16505551212, arr1[0][:phoneNumber]

    arr2 = inf.inflate_to_array('+16505551212')
    assert_equal '+16505551212', arr2[0][:phoneNumber]

    arr3 = inf.inflate_to_array({:phoneNumber=>16505551212})
    assert_equal 16505551212, arr3[0][:phoneNumber]

    arr4 = inf.inflate_to_array([{:phoneNumber=>16505551212}])
    assert_equal 16505551212, arr4[0][:phoneNumber]   

  end
end