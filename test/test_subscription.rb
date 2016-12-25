require './test/test_base.rb'

class RingCentralSdkSubscriptionTest < Test::Unit::TestCase
  def setup
    @rcsdk = RingCentralSdk::REST::Client.new do |config|
      config.app_key = 'my_app_key'
      config.app_secret = 'my_app_secret'
      config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
    end
  end

  def test_main
    sub = @rcsdk.create_subscription()
    assert_equal 'RingCentralSdk::REST::Subscription', sub.class.name

    assert_equal 0, sub.event_filters.length

    sub.add_events(['/restapi/v1.0/account/~/extension/~/message-store'])
    assert_equal 1, sub.event_filters.length

    sub.add_events(['/restapi/v1.0/account/~/extension/~/presence'])
    assert_equal 2, sub.event_filters.length
    
    sub.set_events(['/restapi/v1.0/account/~/extension/~/presence'])
    assert_equal 1, sub.event_filters.length

    assert_equal false, sub.alive?

    assert_raise do
      sub.add_events(nil)
    end

    assert_raise do
      sub.set_events(nil)
    end

    assert_raise do
      sub.subscribe(nil)
    end

    assert_raise do
      sub.renew(nil)
    end

    sub.set_events([])
    
    assert_raise do
      sub.subscribe
    end

    assert_raise do
      sub.renew
    end

    # sub.subscribe(['/restapi/v1.0/account/~/extension/~/presence'])

    sub_data = sub.subscription
    assert_equal sub_data['deliveryMode']['transportType'], 'PubNub'
    assert_equal sub_data['deliveryMode']['encryption'], false
    sub_data['deliveryMode']['encryption'] = true
    sub.set_subscription(sub_data)
    sub_data = sub.subscription
    assert_equal sub_data['deliveryMode']['encryption'], true

    assert_equal nil, sub.pubnub

    sub.destroy
    sub_data = sub.subscription
    assert_equal sub_data['deliveryMode']['encryption'], false
  end

  def get_rcsdk_authorized
    rcsdk = RingCentralSdk::REST::Client.new do |config|
      config.app_key = 'my_app_key'
      config.app_secret = 'my_app_secret'
      config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
    end
    rcsdk.set_oauth2_client

    stub_token_hash = data_test_auth_token
    stub_token = OAuth2::AccessToken::from_hash(rcsdk.oauth2client, stub_token_hash)

    rcsdk.oauth2client.password.stubs(:get_token).returns(stub_token)

    token = rcsdk.authorize('my_test_username', 'my_test_extension', 'my_test_password')
    return rcsdk
  end

  def test_subscribe_renew_delete_with_exceptions
    # Get RCSDK Authroized
    rcsdk = get_rcsdk_authorized()
    # Stub Subscribe RC Response
    data = data_test_subscribe()
    response = Faraday::Response.new
    response.stubs(:body).returns(data)
    rcsdk.http.stubs(:post).returns(response)
    rcsdk.http.stubs(:put).returns(response)
    response_del = Faraday::Response.new
    response_del.stubs(:body).returns('')
    rcsdk.http.stubs(:delete).returns(response_del)
    # Stub Pubnub Response
    Pubnub::Client.any_instance.stubs(:subscribe).returns(nil)
    Pubnub::Client.any_instance.stubs(:unsubscribe).returns(nil)
    # Create Subscription
    sub = rcsdk.create_subscription
    # Test subscribe()
    sub.subscribe(['/restapi/v1.0/account/~/extension/~/presence'])
    # Test renew()
    sub.renew(['/restapi/v1.0/account/~/extension/~/presence'])
    assert_raise do
      sub.renew([])
    end
    # Test subscription data
    id = data['id']
    data = sub.subscription()
    assert_equal id.to_s, data['id'].to_s
    id_new = data['id'] += 'modified'
    sub.set_subscription(data)
    assert_equal id_new.to_s, data['id'].to_s
    # Test register()
    sub.register(['/restapi/v1.0/account/~/extension/~/presence'])
    # Test remove
    sub.remove
    # Test Exceptions
    rcsdk2 = get_rcsdk_authorized
    rcsdk2.http.stubs(:post).raises('error')
    rcsdk2.http.stubs(:put).raises('error')
    rcsdk2.http.stubs(:delete).raises('error')
    sub2 = rcsdk2.create_subscription
    assert_raise do
      sub2.subscribe(['/restapi/v1.0/account/~/extension/~/presence'])
    end
    assert_raise do
      sub2.renew(['/restapi/v1.0/account/~/extension/~/presence'])
    end
    assert_raise do
      sub2.remove()
    end
  end

  def test_decrypt_encrypted
    rcsdk = get_rcsdk_authorized()
    sub = rcsdk.create_subscription()
    data = data_test_subscribe()
    sub.set_subscription(data)
    plaintext_src = '{"hello":"world"}'
    # Encrypt test data
    cipher = OpenSSL::Cipher::AES.new(128, :ECB)
    cipher.encrypt
    cipher.key = Base64.decode64(data['deliveryMode']['encryptionKey'])
    ciphertext = cipher.update(plaintext_src) + cipher.final
    ciphertext64 = Base64.encode64(ciphertext)
    # Decrypt to JSON decoded as hash
    plaintext_out = sub._decrypt(ciphertext64)
    assert_equal 'world', plaintext_out['hello']
  end

  def data_test_auth_token
    json = '{
  "access_token": "my_test_access_token",
  "token_type": "bearer",
  "expires_in": 3599,
  "refresh_token": "my_test_refresh_token",
  "refresh_token_expires_in": 604799,
  "scope": "ReadCallLog DirectRingOut EditCallLog ReadAccounts Contacts EditExtensions ReadContacts SMS EditPresence RingOut EditCustomData ReadPresence EditPaymentInfo Interoperability Accounts NumberLookup InternalMessages ReadCallRecording EditAccounts Faxes EditReportingSettings ReadClientInfo EditMessages VoipCalling ReadMessages",
  "owner_id": "1234567890"
      }'
    JSON.parse(json, symbolize_names: true)
  end

  def data_test_subscribe
    json = '{
  "id": "mySubscriptionId",
  "creationTime": "2015-10-18T16:41:30.048Z",
  "status": "Active",
  "uri": "https://platform.devtest.ringcentral.com/restapi/v1.0/subscription/mySubscriptionId",
  "eventFilters": [
    "/restapi/v1.0/account/1234567890/extension/1234567890/presence"
  ],
  "expirationTime": "2015-10-18T16:56:30.048Z",
  "expiresIn": 899,
  "deliveryMode": {
    "transportType": "PubNub",
    "encryption": true,
    "address": "1234567890_deadbeef",
    "subscriberKey": "sub-c-deadbeef",
    "encryptionAlgorithm": "AES",
    "encryptionKey": "/UjxdHILResI0XWzhXIilQ=="
  }
}'
    JSON.parse(json)
  end

  def test_pubnub
    sub = @rcsdk.create_subscription()
    pub = sub.new_pubnub('test', false, '')

    assert_equal 'Pubnub::Client', pub.class.name
  end
end
