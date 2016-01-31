require './test/test_base.rb'

require 'multi_json'

class RingCentralSdkRESTEventTest < Test::Unit::TestCase
  def test_new_sms_count
    data = data_test_hash()

    event = RingCentralSdk::REST::Event.new(data, :force=>true)

    assert_equal '11111111-2222-3333-4444-555555555555', event.doc.getAttr('uuid')
    assert_equal 1, event.new_sms_count
  end

  def data_test_hash(opts={})
    json = data_test_json()
    hash = MultiJson.decode(json, :symbolize_keys=>false)
    return hash
  end

  def data_test_json()
    json = '{"uuid":"11111111-2222-3333-4444-555555555555","event":"/restapi/v1.0/account/~/extension/22222222/message-store","timestamp":"2016-01-31T00:15:30.196Z","body":{"extensionId":22222222,"lastUpdated":"2016-01-31T00:15:15.923+0000","changes":[{"type":"SMS","newCount":1,"updatedCount":1}]}}'
  end
end
