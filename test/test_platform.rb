require './test/test_helper.rb'

require 'faraday'
require 'oauth2'

class RingCentralSdkPlatformTest < Test::Unit::TestCase
  def setup
    @rcsdk = RingCentralSdk.new(
      'my_app_key',
      'my_app_secret',
      RingCentralSdk::RC_SERVER_SANDBOX
    )
  end

  def test_main
    assert_equal "bXlfYXBwX2tleTpteV9hcHBfc2VjcmV0", @rcsdk.platform.send(:get_api_key)
  end

  def test_set_client
    rcsdk = new_rcsdk()
    assert_equal true, rcsdk.platform.oauth2client.is_a?(OAuth2::Client)

    rcsdk.platform.set_oauth2_client()
    assert_equal true, rcsdk.platform.oauth2client.is_a?(OAuth2::Client)

    rcsdk = new_rcsdk()
    oauth2client = OAuth2::Client.new(
      'my_app_key',
      'my_app_secret',
      :site      => RingCentralSdk::RC_SERVER_SANDBOX,
      :token_url => rcsdk.platform.class::TOKEN_ENDPOINT)
    rcsdk.platform.set_oauth2_client(oauth2client)
    assert_equal true, rcsdk.platform.oauth2client.is_a?(OAuth2::Client) 

    assert_raise do
      @rcsdk.platform.set_oauth2_client('test')
    end
  end

  def test_set_token
    token_data = {:access_token => 'test_token'}

    @rcsdk.platform.set_token(token_data)

    assert_equal 'OAuth2::AccessToken', @rcsdk.platform.token.class.name
    assert_equal 'Faraday::Connection', @rcsdk.platform.client.class.name

    assert_raise do
      @rcsdk.platform.set_token('test')
    end
  end

  def test_authorize_url_default
    rcsdk = RingCentralSdk::Sdk.new(
      'my_app_key',
      'my_app_secret',
      RingCentralSdk::RC_SERVER_PRODUCTION,
      {:redirect_uri => 'http://localhost:4567/oauth'}
    )
    authorize_url = rcsdk.platform.authorize_url()

    assert_equal true, authorize_url.is_a?(String)
    assert_equal 0, authorize_url.index(RingCentralSdk::RC_SERVER_PRODUCTION)
    assert_equal true, (authorize_url.index('localhost') > 0) ? true : false
  end

  def test_authorize_url_explicit
    authorize_url = @rcsdk.platform.authorize_url({:redirect_uri => 'http://localhost:4567/oauth'})

    assert_equal 0, authorize_url.index(RingCentralSdk::RC_SERVER_SANDBOX)
    assert_equal true, (authorize_url.index('localhost') > 0) ? true : false
  end

  def test_create_url
    assert_equal '/restapi/v1.0/subscribe', @rcsdk.platform.create_url('subscribe')
    assert_equal '/restapi/v1.0/subscribe', @rcsdk.platform.create_url('/subscribe')
    assert_equal RingCentralSdk::RC_SERVER_SANDBOX + '/restapi/v1.0/subscribe', @rcsdk.platform.create_url('subscribe', true)
  end

  def test_authorize_code
    rcsdk = new_rcsdk()
    rcsdk.platform.set_oauth2_client()

    stub_token_hash = data_auth_token
    stub_token = OAuth2::AccessToken::from_hash(rcsdk.platform.oauth2client, stub_token_hash)

    rcsdk.platform.oauth2client.auth_code.stubs(:get_token).returns(stub_token)

    token = rcsdk.platform.authorize_code('my_test_auth_code')
    assert_equal 'OAuth2::AccessToken', token.class.name
    assert_equal 'OAuth2::AccessToken', rcsdk.platform.token.class.name

    rcsdk = new_rcsdk({:redirect_uri => 'http://localhost:4567/oauth'})
    rcsdk.platform.set_oauth2_client()

    stub_token_hash = data_auth_token
    stub_token = OAuth2::AccessToken::from_hash(rcsdk.platform.oauth2client, stub_token_hash)

    rcsdk.platform.oauth2client.auth_code.stubs(:get_token).returns(stub_token)

    token = rcsdk.platform.authorize_code('my_test_auth_code')
    assert_equal 'OAuth2::AccessToken', token.class.name
    assert_equal 'OAuth2::AccessToken', rcsdk.platform.token.class.name

    rcsdk = new_rcsdk()
    rcsdk.platform.set_oauth2_client()

    stub_token_hash = data_auth_token
    stub_token = OAuth2::AccessToken::from_hash(rcsdk.platform.oauth2client, stub_token_hash)

    rcsdk.platform.oauth2client.auth_code.stubs(:get_token).returns(stub_token)

    token = rcsdk.platform.authorize_code('my_test_auth_code')
    assert_equal 'OAuth2::AccessToken', token.class.name
    assert_equal 'OAuth2::AccessToken', rcsdk.platform.token.class.name

    rcsdk = new_rcsdk()
    rcsdk.platform.set_oauth2_client()

    stub_token_hash = data_auth_token
    stub_token = OAuth2::AccessToken::from_hash(rcsdk.platform.oauth2client, stub_token_hash)

    rcsdk.platform.oauth2client.auth_code.stubs(:get_token).returns(stub_token)

    token = rcsdk.platform.authorize_code('my_test_auth_code', {:redirect_uri => 'http://localhost:4567/oauth'})
    assert_equal 'OAuth2::AccessToken', token.class.name
    assert_equal 'OAuth2::AccessToken', rcsdk.platform.token.class.name
  end

  def test_authorize_password
    rcsdk = new_rcsdk()
    rcsdk.platform.set_oauth2_client()

    stub_token_hash = data_auth_token
    stub_token = OAuth2::AccessToken::from_hash(rcsdk.platform.oauth2client, stub_token_hash)

    rcsdk.platform.oauth2client.password.stubs(:get_token).returns(stub_token)

    token = rcsdk.platform.authorize('my_test_username', 'my_test_extension', 'my_test_password')
    assert_equal 'OAuth2::AccessToken', token.class.name
    assert_equal 'OAuth2::AccessToken', rcsdk.platform.token.class.name
  end

  def test_request
    assert_raise do
      @rcsdk.platform.request()
    end

    rcsdk = new_rcsdk()
    rcsdk.platform.set_oauth2_client()

    stub_token_hash = data_auth_token
    stub_token = OAuth2::AccessToken::from_hash(rcsdk.platform.oauth2client, stub_token_hash)

    rcsdk.platform.oauth2client.password.stubs(:get_token).returns(stub_token)

    token = rcsdk.platform.authorize('my_test_username', 'my_test_extension', 'my_test_password')

    #@rcsdk.platform.client.stubs(:post).returns(Faraday::Response.new)
    Faraday::Connection.any_instance.stubs(:post).returns(Faraday::Response.new)

    fax = RingCentralSdk::Helpers::CreateFaxRequest.new(
      nil, # Can be nil or {} for defaults '~'
      {
        # phone numbers are in E.164 format with or without leading '+'
        :to            => '+16505551212',
        :faxResolution => 'High',
        :coverPageText => 'RingCentral fax demo using Ruby SDK!'
      },
      :text => 'RingCentral fax demo using Ruby SDK!'
    )
    res = rcsdk.platform.request(fax)
    assert_equal 'Faraday::Response', res.class.name
  end

  def new_rcsdk(opts={})
    return RingCentralSdk::Sdk.new(
      'my_app_key',
      'my_app_secret',
      RingCentralSdk::RC_SERVER_PRODUCTION,
      opts
    )
  end

  def data_auth_token
    json = '{
  "access_token": "my_test_access_token",
  "token_type": "bearer",
  "expires_in": 3599,
  "refresh_token": "my_test_refresh_token",
  "refresh_token_expires_in": 604799,
  "scope": "ReadCallLog DirectRingOut EditCallLog ReadAccounts Contacts EditExtensions ReadContacts SMS EditPresence RingOut EditCustomData ReadPresence EditPaymentInfo Interoperability Accounts NumberLookup InternalMessages ReadCallRecording EditAccounts Faxes EditReportingSettings ReadClientInfo EditMessages VoipCalling ReadMessages",
  "owner_id": "1234567890"
      }'
    data = JSON.parse(json, :symbolize_names=>true)
    return data
  end
end