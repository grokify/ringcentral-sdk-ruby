module RingCentralSdk
  VERSION = '0.5.0'

  RC_SERVER_PRODUCTION = 'https://platform.ringcentral.com'
  RC_SERVER_SANDBOX    = 'https://platform.devtest.ringcentral.com'

  autoload :Helpers, 'ringcentral_sdk/helpers'
  autoload :Platform, 'ringcentral_sdk/platform'
  autoload :Sdk, 'ringcentral_sdk/sdk'
  autoload :Subscription, 'ringcentral_sdk/subscription'

  class << self

    def new(app_key=nil, app_secret=nil, server_url=nil, opts={})
      RingCentralSdk::Platform.new(app_key, app_secret, server_url, opts)
    end

  end
end