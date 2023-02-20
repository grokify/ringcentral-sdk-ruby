require './test/test_base.rb'

class RingCentralSdkRESTExtensionPresenceTest < Test::Unit::TestCase
  def new_client
    RingCentralSdk::REST::Client.new do |config|
      config.client_id = 'my_app_client_id'
      config.client_secret = 'my_app_client_secret'
      config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
    end
  end

  def test_department_calls_enable
    presence = RingCentralSdk::REST::ExtensionPresence.new(111_111)

    cur_status = 'TakeAllCalls'
    assert_equal \
      'DoNotAcceptDepartmentCalls', \
      presence.new_status_dnd_department_calls(cur_status, false)

    assert_equal \
      'TakeAllCalls', \
      presence.new_status_dnd_department_calls(cur_status, true)

    cur_status = 'TakeDepartmentCallsOnly'
    assert_equal \
      'DoNotAcceptAnyCalls', \
      presence.new_status_dnd_department_calls(cur_status, false)
    assert_equal \
      'TakeDepartmentCallsOnly', \
      presence.new_status_dnd_department_calls(cur_status, true)

    cur_status = 'DoNotAcceptAnyCalls'

    assert_equal \
      'DoNotAcceptAnyCalls', \
      presence.new_status_dnd_department_calls(cur_status, false)
    assert_equal \
      'TakeDepartmentCallsOnly', \
      presence.new_status_dnd_department_calls(cur_status, true)

    cur_status = 'DoNotAcceptDepartmentCalls'
    assert_equal \
      'DoNotAcceptDepartmentCalls', \
      presence.new_status_dnd_department_calls(cur_status, false)
    assert_equal \
      'TakeAllCalls', \
      presence.new_status_dnd_department_calls(cur_status, true)
  end

  def test_retrieve
    stub_auth = RingCentralSdkTestSubAuth.new
    client = stub_auth.new_client_with_auth
    stub_presence = data_extension_presence

    Faraday::Connection.any_instance.stubs(:get).returns(Faraday::Response.new)
    Faraday::Connection.any_instance.stubs(:put).returns(Faraday::Response.new)

    presence = RingCentralSdk::REST::ExtensionPresence.new(111_111, client: client)
    presence.retrieve
    presence.presence_data = stub_presence

    assert_equal 'TakeAllCalls', presence.presence_data['dndStatus']

    assert_equal true, presence.department_calls_enabled?

    # new_status = presence.department_calls_enable false
    # assert_equal 'DoNotAcceptDepartmentCalls', new_status

    presence.extension_id = 'abc'
    assert_raise do
      presence.retrieve
    end

    assert_raise do
      presence.update nil
    end

    presence.update(dndStatus: 'TakeAllCalls')

    ######
    # Test with good data
    ######

    assert_raise do
      presence.department_calls_enable true
    end
  end

  def data_extension_presence
    json = '{
  "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/111111/extension/222222/presence",
  "extension": {
    "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/account/111111/extension/222222",
    "id": 222222,
    "extensionNumber": "102"
  },
  "presenceStatus": "Available",
  "telephonyStatus": "NoCall",
  "userStatus": "Available",
  "dndStatus": "TakeAllCalls",
  "allowSeeMyPresence": true,
  "ringOnMonitoredCall": false,
  "pickUpCallsOnHold": false
}'
    JSON.parse json, symbolize_names: false
  end
end

class RingCentralSdkTestSubAuth
  def new_client
    RingCentralSdk::REST::Client.new do |config|
      config.client_id = 'my_app_client_id'
      config.client_secret = 'my_app_client_secret'
      config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
    end
  end

  def new_client_with_auth
    client = new_client
    client.set_oauth2_client

    stub_token_hash = data_auth_token_with_refresh
    stub_token = OAuth2::AccessToken.from_hash(client.oauth2client, stub_token_hash)

    client.oauth2client.password.stubs(:get_token).returns(stub_token)
    client.authorize('my_test_username', 'my_test_extension', 'my_test_password')
    client
  end

  def data_auth_token_with_refresh
    json = '{
      "access_token": "my_test_access_token_with_refresh",
      "token_type": "bearer",
      "expires_in": 3599,
      "refresh_token": "my_test_refresh_token",
      "refresh_token_expires_in": 604799,
      "scope": "ReadCallLog DirectRingOut EditCallLog ReadAccounts Contacts EditExtensions ReadContacts SMS EditPresence RingOut EditCustomData ReadPresence EditPaymentInfo Interoperability Accounts NumberLookup InternalMessages ReadCallRecording EditAccounts Faxes EditReportingSettings ReadClientInfo EditMessages VoipCalling ReadMessages",
      "owner_id": "1234567890"
      }'
    JSON.parse(json, symbolize_names: true)
  end

  def data_auth_token_without_refresh
    json = '{
      "access_token": "my_test_access_token_without_refresh",
      "token_type": "bearer",
      "expires_in": 3599,
      "scope": "ReadCallLog DirectRingOut EditCallLog ReadAccounts Contacts EditExtensions ReadContacts SMS EditPresence RingOut EditCustomData ReadPresence EditPaymentInfo Interoperability Accounts NumberLookup InternalMessages ReadCallRecording EditAccounts Faxes EditReportingSettings ReadClientInfo EditMessages VoipCalling ReadMessages",
      "owner_id": "1234567890"
      }'
    JSON.parse(json, symbolize_names: true)
  end
end
