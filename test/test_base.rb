require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'mocha/test_unit'
require 'ringcentral_sdk'

RingCentralSdk::REST::Client.new do |config|
  config.client_id = 'my_app_client_id'
  config.client_secret = 'my_app_client_secret'
  config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
end

module RingCentralSdk
  module Test
    class ClientUtil
      def new_client_with_auth
        client = new_client
        client.set_oauth2_client

        stub_token_hash = data_auth_token_with_refresh
        stub_token = OAuth2::AccessToken.from_hash(client.oauth2client, stub_token_hash)

        client.oauth2client.password.stubs(:get_token).returns(stub_token)

        client.authorize('my_test_username', 'my_test_extension', 'my_test_password')
      end

      def client_stub_auth(client)
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
  end
end
