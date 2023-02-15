require './test/test_base.rb'

class RingCentralSdkHelperInflatorContactInfoTest < Test::Unit::TestCase
  def test_setup
    inf  = RingCentralSdk::REST::Request::Inflator::ContactInfo.new

    arr1 = inf.inflate_to_array 1_650_555_121_2
    assert_equal 1_650_555_121_2, arr1[0][:phoneNumber]

    arr2 = inf.inflate_to_array '+16505551212'
    assert_equal '+16505551212', arr2[0][:phoneNumber]

    arr3 = inf.inflate_to_array(phoneNumber: 1_650_555_121_2)
    assert_equal 1_650_555_121_2, arr3[0][:phoneNumber]

    arr4 = inf.inflate_to_array([{ phoneNumber: 1_650_555_121_2 }])
    assert_equal 1_650_555_121_2, arr4[0][:phoneNumber]
  end
end
