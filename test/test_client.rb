require './test/test_base.rb'

require 'faraday'
require 'oauth2'

class RingCentralSdkPlatformTest < Test::Unit::TestCase
  def setup
    @rcsdk = RingCentralSdk::REST::Client.new do |config|
      config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
      config.client_id = 'my_app_client_id'
      config.client_secret = 'my_app_client_secret'
    end
  end

  def test_main
    assert_equal 'bXlfYXBwX2NsaWVudF9pZDpteV9hcHBfY2xpZW50X3NlY3JldA==', @rcsdk.send(:api_key)
  end

  def test_config
    redirect_url = 'http://localhost:4567/oauth'
    client = RingCentralSdk::REST::Client.new do |config|
      config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
      config.client_id = 'my_app_client_id'
      config.client_secret = 'my_app_client_secret'
      config.redirect_url = redirect_url
    end
    assert_equal redirect_url, client.config.redirect_url
  end

  def test_set_client
    rcsdk = new_client
    assert_equal true, rcsdk.oauth2client.is_a?(OAuth2::Client)

    rcsdk.set_oauth2_client
    assert_equal true, rcsdk.oauth2client.is_a?(OAuth2::Client)

    rcsdk = new_client
    oauth2client = OAuth2::Client.new(
      'my_app_client_id',
      'my_app_client_secret',
      site: RingCentralSdk::RC_SERVER_SANDBOX,
      token_url: rcsdk.class::TOKEN_ENDPOINT
    )
    rcsdk.set_oauth2_client oauth2client
    assert_equal true, rcsdk.oauth2client.is_a?(OAuth2::Client)

    assert_raise { @rcsdk.set_oauth2_client('test') }
  end

  def test_set_token
    token_data = { access_token: 'test_token' }

    @rcsdk.set_token(token_data)

    token = @rcsdk.token

    assert_equal 'OAuth2::AccessToken', token.class.name
    assert_equal 'Faraday::Connection', @rcsdk.http.class.name

    assert_raise do
      @rcsdk.set_token('test')
    end
  end

  def test_authorize_url_default
    rcsdk = RingCentralSdk::REST::Client.new do |config|
      config.client_id = 'my_app_client_id'
      config.client_secret = 'my_app_client_secret'
      config.server_url = RingCentralSdk::RC_SERVER_PRODUCTION
      config.redirect_url = 'http://localhost:4567/oauth'
    end

    authorize_url = rcsdk.authorize_url

    puts authorize_url

    assert_equal true, authorize_url.is_a?(String)
    assert_equal 0, authorize_url.index(RingCentralSdk::RC_SERVER_PRODUCTION)
    assert_equal true, authorize_url.index('localhost') > 0 ? true : false
  end

  def test_authorize_url_explicit
    authorize_url = @rcsdk.authorize_url(redirect_uri: 'http://localhost:4567/oauth')

    assert_equal 0, authorize_url.index(RingCentralSdk::RC_SERVER_SANDBOX)
    assert_equal true, authorize_url.index('localhost') > 0 ? true : false
  end

  def test_create_url
    assert_equal '/restapi/v1.0/subscribe', @rcsdk.create_url('subscribe')
    assert_equal '/restapi/v1.0/subscribe', @rcsdk.create_url('/subscribe')
    assert_equal RingCentralSdk::RC_SERVER_SANDBOX + '/restapi/v1.0/subscribe', @rcsdk.create_url('subscribe', true)
    assert_equal RingCentralSdk::RC_SERVER_SANDBOX + '/restapi/v1.0/subscribe', @rcsdk.create_url('/subscribe', true)
    assert_equal RingCentralSdk::RC_SERVER_SANDBOX + '/restapi/v1.0/subscribe', @rcsdk.create_url('subscribe', true)
    assert_equal RingCentralSdk::RC_SERVER_SANDBOX + '/restapi/v1.0/subscribe', @rcsdk.create_url('/subscribe', true)
  end

  def test_create_urls
    urls = @rcsdk.create_urls(['subscribe'])
    assert_equal '/restapi/v1.0/subscribe', urls[0]
    assert_raise do
      @rcsdk.create_urls(nil)
    end
  end

  def test_authorize_code
    rcsdk = new_client
    rcsdk.set_oauth2_client

    stub_token_hash = data_auth_token_with_refresh
    stub_token = OAuth2::AccessToken.from_hash(rcsdk.oauth2client, stub_token_hash)

    rcsdk.oauth2client.auth_code.stubs(:get_token).returns(stub_token)

    token = rcsdk.authorize_code('my_test_auth_code')
    assert_equal 'OAuth2::AccessToken', token.class.name
    assert_equal 'OAuth2::AccessToken', rcsdk.token.class.name

    rcsdk = RingCentralSdk::REST::Client.new do |config|
      config.client_id = 'my_app_client_id'
      config.client_secret = 'my_app_client_secret'
      config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
      config.redirect_url = 'http://localhost:4567/oauth'
    end

    rcsdk.set_oauth2_client

    stub_token_hash = data_auth_token_with_refresh
    stub_token = OAuth2::AccessToken.from_hash(rcsdk.oauth2client, stub_token_hash)

    rcsdk.oauth2client.auth_code.stubs(:get_token).returns(stub_token)

    token = rcsdk.authorize_code('my_test_auth_code')
    assert_equal 'OAuth2::AccessToken', token.class.name
    assert_equal 'OAuth2::AccessToken', rcsdk.token.class.name

    rcsdk = new_client
    rcsdk.set_oauth2_client

    stub_token_hash = data_auth_token
    stub_token = OAuth2::AccessToken.from_hash(rcsdk.oauth2client, stub_token_hash)

    rcsdk.oauth2client.auth_code.stubs(:get_token).returns(stub_token)

    token = rcsdk.authorize_code('my_test_auth_code')
    assert_equal 'OAuth2::AccessToken', token.class.name
    assert_equal 'OAuth2::AccessToken', rcsdk.token.class.name

    rcsdk = new_client
    rcsdk.set_oauth2_client

    stub_token_hash = data_auth_token
    stub_token = OAuth2::AccessToken.from_hash(rcsdk.oauth2client, stub_token_hash)

    rcsdk.oauth2client.auth_code.stubs(:get_token).returns(stub_token)

    token = rcsdk.authorize_code('my_test_auth_code', redirect_uri: 'http://localhost:4567/oauth')
    assert_equal 'OAuth2::AccessToken', token.class.name
    assert_equal 'OAuth2::AccessToken', rcsdk.token.class.name
  end

  def test_authorize_password_with_refresh
    rcsdk = new_client
    rcsdk.set_oauth2_client

    stub_token_hash = data_auth_token_with_refresh
    stub_token = OAuth2::AccessToken.from_hash(rcsdk.oauth2client, stub_token_hash)

    rcsdk.oauth2client.password.stubs(:get_token).returns(stub_token)

    token = rcsdk.authorize('my_test_username', 'my_test_extension', 'my_test_password')
    assert_equal 'OAuth2::AccessToken', token.class.name
    assert_equal 'OAuth2::AccessToken', rcsdk.token.class.name
    assert_equal 'my_test_access_token_with_refresh', rcsdk.token.token
  end

  def test_authorize_password_without_refresh
    rcsdk = new_client
    rcsdk.set_oauth2_client

    stub_token_hash = data_auth_token_without_refresh
    stub_token = OAuth2::AccessToken.from_hash(rcsdk.oauth2client, stub_token_hash)

    rcsdk.oauth2client.password.stubs(:get_token).returns(stub_token)

    token = rcsdk.authorize('my_test_username', 'my_test_extension', 'my_test_password')
    assert_equal 'OAuth2::AccessToken', token.class.name
    assert_equal 'OAuth2::AccessToken', rcsdk.token.class.name
    assert_equal 'my_test_access_token_without_refresh', rcsdk.token.token
  end

  def test_request
    assert_raise do
      @rcsdk.request
    end

    client = new_client
    client.set_oauth2_client

    stub_token_hash = data_auth_token_with_refresh
    stub_token = OAuth2::AccessToken.from_hash(client.oauth2client, stub_token_hash)

    client.oauth2client.password.stubs(:get_token).returns(stub_token)

    client.authorize('my_test_username', 'my_test_extension', 'my_test_password')

    # @rcsdk.client.stubs(:post).returns(Faraday::Response.new)
    Faraday::Connection.any_instance.stubs(:post).returns(Faraday::Response.new)

    fax = RingCentralSdk::REST::Request::Fax.new(
      # phone numbers are in E.164 format with or without leading '+'
      to: '+16505551212',
      faxResolution: 'High',
      coverPageText: 'RingCentral fax demo using Ruby SDK!',
      text: 'RingCentral fax demo using Ruby SDK!'
    )
    res = client.send_request(fax)
    assert_equal 'Faraday::Response', res.class.name

    assert_raise do
      res = client.send_request('non-fax')
    end

    res = client.messages.fax.create(
      to: '+16505551212',
      faxResolution: 'High',
      coverPageText: 'RingCentral fax demo using Ruby SDK!',
      text: 'RingCentral fax demo using Ruby SDK!'
    )
    assert_equal 'Faraday::Response', res.class.name

    ######
    # Simple Request - GET
    ######
    request = RingCentralSdk::REST::Request::Simple.new(
      method: 'get',
      url: 'account/~/extension/~/message-store',
      params: {
        direction: 'Inbound',
        messageType: 'SMS'
      }
    )
    assert_equal 'get', request.method

    res = client.send_request request
    assert_equal 'Faraday::Response', res.class.name

    ######
    # Simple Request - PUT
    ######
    request = RingCentralSdk::REST::Request::Simple.new(
      method: 'put',
      url: 'account/~/extension/~/message-store/11111111',
      body: { readStatus: 'Read' }
    )
    assert_equal 'put', request.method

    res = client.send_request request
    assert_equal 'Faraday::Response', res.class.name

    ######
    # Simple Request - DELETE
    ######
    request = RingCentralSdk::REST::Request::Simple.new(
      method: 'delete',
      url: 'account/~/extension/~/message-store/11111111'
    )
    assert_equal 'delete', request.method

    res = client.send_request request
    assert_equal 'Faraday::Response', res.class.name
  end

  def test_sms
    client = new_client
    client.set_oauth2_client

    stub_token_hash = data_auth_token_with_refresh
    stub_token = OAuth2::AccessToken.from_hash(client.oauth2client, stub_token_hash)

    client.oauth2client.password.stubs(:get_token).returns(stub_token)

    client.authorize('my_test_username', 'my_test_extension', 'my_test_password')

    res = client.messages.sms.create(
      from: '+16505551212',
      to: '+14155551212',
      text: 'test'
    )
    assert_equal 'Faraday::Response', res.class.name

    res = client.send_request(
      method: 'post',
      url: 'account/~/extension/~/sms',
      body: {
        from: { phoneNumber: '+16505551212' },
        to: { phoneNumber: '+14155551212' },
        text: 'Hi there!'
      }
    )
    assert_equal 'Faraday::Response', res.class.name
  end

  def new_client
    RingCentralSdk::REST::Client.new do |config|
      config.client_id = 'my_app_client_id'
      config.client_secret = 'my_app_client_secret'
      config.server_url = RingCentralSdk::RC_SERVER_PRODUCTION
    end
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

  alias data_auth_token data_auth_token_with_refresh
end
