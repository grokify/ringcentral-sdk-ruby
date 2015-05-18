require './test/test_helper.rb'

class RingCentralSdkHelperFaxTest < Test::Unit::TestCase
  def testSetup

    fax = RingCentralSdk::Helpers::CreateFaxRequest.new(
      nil, # Can be nil or {} for defaults '~'
      {
        # phone numbers are in E.164 format with or without leading '+'
        :to            => [{ :phoneNumber => '+16505551212' }],
        :faxResolution => 'High',
        :coverPageText => 'RingCentral fax demo using Ruby SDK!'
      },
      :text => 'RingCentral fax demo using Ruby SDK!'
    )

    assert_equal "RingCentralSdk::Helpers::CreateFaxRequest", fax.class.name
    assert_equal 'account/~/extension/~/fax', fax.url()

    fax2 = RingCentralSdk::Helpers::CreateFaxRequest.new(
      { :account_id => '111111111', :extension_id => '222222222' }, # Can be nil or {} for defaults '~'
      {
        # phone numbers are in E.164 format with or without leading '+'
        :to            => [{ :phoneNumber => '+16505551212' }],
        :faxResolution => 'High',
        :coverPageText => 'RingCentral fax demo using Ruby SDK!'
      },
      :text => 'RingCentral fax demo using Ruby SDK!'
    )

    assert_equal 'account/111111111/extension/222222222/fax', fax2.url()

  end
end