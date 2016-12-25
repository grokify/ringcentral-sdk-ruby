require './test/test_base.rb'

class RingCentralSdkTest < Test::Unit::TestCase
  def setup
    @rcsdk = RingCentralSdk::REST::Client.new do |config|
      config.app_key = 'my_app_key'
      config.app_secret = 'my_app_secret'
      config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
    end
  end

  def test_main
    assert_equal 'RingCentralSdk::REST::Client', @rcsdk.class.name

    assert_raise do
      @rcsdk.send_request(nil)
    end

    rcsdk = RingCentralSdk::REST::Client.new do |config|
      config.app_key = 'my_app_key'
      config.app_secret = 'my_app_secret'
      config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
    end
    assert_equal 'RingCentralSdk::REST::Client', rcsdk.class.name
  end

  def test_login
    stub_token_hash = data_auth_token
    stub_token = OAuth2::AccessToken::from_hash(@rcsdk.oauth2client, stub_token_hash)

    OAuth2::Strategy::Password.any_instance.stubs(:get_token).returns(stub_token)
    
    rcsdk = RingCentralSdk::REST::Client.new do |config|
      config.app_key = 'my_app_key'
      config.app_secret = 'my_app_secret'
      config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
      config.username = 'my_username'
      config.password = 'my_password'
    end
  end

  def data_auth_token
    json = '{
  "access_token": "my_test_access_token",
  "token_type": "bearer",
  "expires_in": 3599,
  "refresh_token": "my_test_refresh_token",
  "refresh_token_expires_in": 604799,
  "scope": "ReadCallLog DirectRingOut EditCallLog ReadAccounts Contacts EditExtensions ReadContacts SMS EditPresence RingOut EditCustomData ReadPresence EditPaymentInfo Interoperability Accounts NumberLookup InternalMessages ReadCallRecording EditAccounts Faxes EditReportingSettings ReadClientInfo EditMessages VoipCalling ReadMessages",
  "owner_id": "1234567890  "
      }'
    JSON.parse(json, symbolize_names: true)
  end
end

