module RingCentralSdk
  class Sdk

    RC_SERVER_PRODUCTION = 'https://platform.ringcentral.com'
    RC_SERVER_SANDBOX    = 'https://platform.devtest.ringcentral.com'

    attr_reader :platform

    def initialize(app_key=nil, app_secret=nil, server_url=nil, opts={})
      use_pubnub_mock = false

      @platform = RingCentralSdk::Platform.new(app_key, app_secret, server_url, opts)
      if opts.has_key?(:username) && opts.has_key?(:password)
        extension = opts.has_key?(:extension) ? opts[:extension] : ''
        @platform.authorize(opts[:username], extension, opts[:password])
      end
    end

    def request(helper=nil)
      return @platform.request(helper)
    end

    def create_subscription()
      return RingCentralSdk::Subscription.new(@platform)
    end
  end
end