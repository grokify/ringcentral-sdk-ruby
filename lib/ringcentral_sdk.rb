# RingCentralSdk is a SDK for the RingCentral REST API
module RingCentralSdk
  VERSION = '2.0.0'.freeze

  RC_SERVER_PRODUCTION = 'https://platform.ringcentral.com'.freeze
  RC_SERVER_SANDBOX = 'https://platform.devtest.ringcentral.com'.freeze

  autoload :REST, 'ringcentral_sdk/rest'

  class << self
    def new(app_key, app_secret, server_url = RC_SERVER_SANDBOX, opts = {})
      RingCentralSdk::REST::Client.new(app_key, app_secret, server_url, opts)
    end
  end
end
