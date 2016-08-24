module RingCentralSdk
  VERSION = '1.3.0'

  RC_SERVER_PRODUCTION = 'https://platform.ringcentral.com'
  RC_SERVER_SANDBOX    = 'https://platform.devtest.ringcentral.com'

  autoload :REST, 'ringcentral_sdk/rest'

  class << self
    def new(app_key, app_secret, server_url = RC_SERVER_SANDBOX, opts = {})
      RingCentralSdk::REST::Client.new(app_key, app_secret, server_url, opts)
    end
  end
end
