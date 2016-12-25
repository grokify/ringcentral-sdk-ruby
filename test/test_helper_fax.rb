# encoding: utf-8

require './test/test_base.rb'

class RingCentralSdkHelperFaxTest < Test::Unit::TestCase
  def test_setup
    fax = RingCentralSdk::REST::Request::Fax.new(
      # phone numbers are in E.164 format with or without leading '+'
      to: '+16505551212',
      faxResolution: 'High',
      coverPageText: 'RingCentral fax demo using Ruby SDK!',
      text: 'RingCentral fax demo using Ruby SDK!'
    )

    assert_equal 'RingCentralSdk::REST::Request::Fax', fax.class.name
    assert_equal 'account/~/extension/~/fax', fax.url

    fax2 = RingCentralSdk::REST::Request::Fax.new(
      accountId: '111111111',
      extensionId: '222222222',
      to: { phoneNumber: '+16505551212' },
      faxResolution: 'High',
      coverPageText: 'RingCentral fax demo using Ruby SDK Résolution!',
      files: ['./scripts/test_file.pdf']
    )

    assert_equal 'account/111111111/extension/222222222/fax', fax2.url

    assert_raise do
      fax2.add_file('non-existent_file_path')
    end

    # Test UTF-8 metadata and file MIME concatenation
    # body = fax2.body

    fax3 = RingCentralSdk::REST::Request::Fax.new(
      accountId: 111_111_111,
      extensionId: 222_222_222,
      # phone numbers are in E.164 format with or without leading '+'
      to: [{ phoneNumber: '+16505551212' }],
      faxResolution: 'High',
      coverPageText: 'RingCentral fax demo using Ruby SDK!',
      text: 'RingCentral fax demo using Ruby SDK!'
    )

    assert_equal 'account/111111111/extension/222222222/fax', fax3.url

    fax4 = RingCentralSdk::REST::Request::Fax.new(
      accountId: 111_111_111,
      extensionId: 222_222_222, # Can be nil or {} for defaults '~'
      to: '+16505551212","coverPageText":"RingCentral fax demo using Ruby SDK!"}',
      text: 'RingCentral fax demo using Ruby SDK!'
    )
    assert_equal 'account/111111111/extension/222222222/fax', fax4.url

    fax5 = RingCentralSdk::REST::Request::Fax.new(
      accountId: 111_111_111,
      extensionId: 222_222_222, # Can be nil or {} for defaults '~'
      coverPageText: 'RingCentral fax demo using Ruby SDK!',
      text: 'RingCentral fax demo using Ruby SDK!'
    )
    assert_equal 'account/111111111/extension/222222222/fax', fax5.url

    # assert_equal 'application/pdf', fax.get_file_content_type('example.pdf')
    # assert_equal 'attachment', fax.get_attachment_content_disposition()
    # assert_equal 'attachment; filename="example.pdf"', fax.get_attachment_content_disposition('example.pdf')
    # assert_equal 'attachment; filename="example.pdf"', fax.get_attachment_content_disposition('/path/to/example.pdf')
    assert_equal 'post', fax.method

    content_type = fax.content_type
    content_type_prefix = ''
    boundary = ''
    if content_type =~ %r{^(multipart/mixed;\s+boundary=)(.*)$}
      content_type_prefix = $1
      boundary = $2
    end
    assert_equal 'multipart/mixed; boundary=', content_type_prefix

    lines = fax.body.split(/\r?\n/)
    assert_equal '--' + boundary, lines[0]
    assert_equal '--' + boundary + '--', lines[-1]

    fax6 = RingCentralSdk::REST::Request::Fax.new(
      accountId: 111_111_111,
      extensionId: 222_222_222, # Can be nil or {} for defaults '~'
      coverPageText: 'RingCentral fax demo using Ruby SDK!',
      parts: [{ text: 'RingCentral fax demo using Ruby SDK!' }]
    )
    assert_equal 'account/111111111/extension/222222222/fax', fax6.url

    fax7 = RingCentralSdk::REST::Request::Fax.new(
      coverPageText: 'RingCentral fax demo using Ruby SDK!',
      parts: [{ text: 'RingCentral fax demo using Ruby SDK!' }]
    )
    assert_equal '~', fax7.account_id
    assert_equal '~', fax7.extension_id
  end
end
