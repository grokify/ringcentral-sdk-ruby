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

    fax3 = RingCentralSdk::Helpers::CreateFaxRequest.new(
      { :account_id => 111111111, :extension_id => 222222222 }, # Can be nil or {} for defaults '~'
      {
        # phone numbers are in E.164 format with or without leading '+'
        :to            => [{ :phoneNumber => '+16505551212' }],
        :faxResolution => 'High',
        :coverPageText => 'RingCentral fax demo using Ruby SDK!'
      },
      :text => 'RingCentral fax demo using Ruby SDK!'
    )

    assert_equal 'account/111111111/extension/222222222/fax', fax3.url()

    assert_equal 'application/pdf', fax.get_file_content_type('example.pdf')
    assert_equal 'attachment', fax.get_attachment_content_disposition()
    assert_equal 'attachment; filename="example.pdf"', fax.get_attachment_content_disposition('example.pdf')
    assert_equal 'attachment; filename="example.pdf"', fax.get_attachment_content_disposition('/path/to/example.pdf')
    assert_equal 'post', fax.method()

    content_type = fax.content_type()
    content_type_prefix = ''
    boundary = ''
    if content_type =~ /^(multipart\/mixed;\s+boundary=)(.*)$/
      content_type_prefix = $1
      boundary = $2
    end
    assert_equal 'multipart/mixed; boundary=', content_type_prefix

    lines = fax.body.split(/\r?\n/)
    assert_equal '--' + boundary, lines[0]
    assert_equal '--' + boundary + '--', lines[-1]

  end
end