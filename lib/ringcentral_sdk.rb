module RingCentralSdk

  VERSION = '0.5.1'

  RC_SERVER_PRODUCTION = 'https://platform.ringcentral.com'
  RC_SERVER_SANDBOX    = 'https://platform.devtest.ringcentral.com'

  autoload :Helpers, 'ringcentral_sdk/helpers'
  autoload :Platform, 'ringcentral_sdk/platform'
  autoload :Simple, 'ringcentral_sdk/simple'
  autoload :Subscription, 'ringcentral_sdk/subscription'

  class << self
    def new(app_key, app_secret, server_url=RC_SERVER_SANDBOX, opts={})
      RingCentralSdk::Platform.new(app_key, app_secret, server_url, opts)
    end
  end

end