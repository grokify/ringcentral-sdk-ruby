require './test/test_base.rb'
require 'multi_json'

class RingCentralSdkRESTEventTest < Test::Unit::TestCase
  def test_new_sms_count
    data = data_test_json_sms

    event = RingCentralSdk::REST::Event.new data

    assert_equal '11112222-3333-4444-5555-666677778888', event.doc.getAttr('uuid')
    assert_equal 1, event.new_sms_count
    assert_equal -1, event.new_fax_count
  end

  def test_new_fax_count
    data = data_test_json_fax()

    event = RingCentralSdk::REST::Event.new data

    assert_equal '11112222-3333-4444-5555-666677778888', event.doc.getAttr('uuid')
    assert_equal -1, event.new_sms_count
    assert_equal 1, event.new_fax_count
  end

  def test_new_empty
    event = RingCentralSdk::REST::Event.new
    assert_equal 'RingCentralSdk::REST::Event', event.class.name
  end

  def test_new_failure
    assert_raise do
      event = RingCentralSdk::REST::Event.new ''
    end
  end

  def data_test_hash(opts={})
    json = data_test_json()
    hash = MultiJson.decode(json, symbolize_keys: false)
    return hash
  end

  def data_test_json_sms
    json = '{"uuid":"11112222-3333-4444-5555-666677778888","event":"/restapi/v1.0/account/~/extension/22222222/message-store","timestamp":"2016-01-31T00:15:30.196Z","body":{"extensionId":22222222,"lastUpdated":"2016-01-31T00:15:15.923+0000","changes":[{"type":"SMS","newCount":1,"updatedCount":1}]}}'
    MultiJson.decode(json, symbolize_keys: true)
  end

  def data_test_json_fax
    json = '{"uuid":"11112222-3333-4444-5555-666677778888","event":"/restapi/v1.0/account/~/extension/22222222/message-store","timestamp":"2016-02-07T14:28:29.010Z","body":{"extensionId":22222222,"lastUpdated":"2016-02-07T14:28:21.961+0000","changes":[{"type":"Fax","newCount":1,"updatedCount":0}]}}'
    MultiJson.decode(json, symbolize_keys: false)
  end
end
