module RingCentralSdk
  class Sdk

    RC_SERVER_PRODUCTION = 'https://platform.ringcentral.com'
    RC_SERVER_SANDBOX    = 'https://platform.devtest.ringcentral.com'

    attr_reader :platform

    def initialize(app_key=nil,app_secret=nil,server_url=nil,username=nil,extension=nil,password=nil)
      use_pubnub_mock = false

      @platform = RingCentralSdk::Platform::Platform.new(app_key, app_secret, server_url)
      if not username.nil? and not password.nil?
        @platform.authorize(username, extension, password)
      end

      @_pubnub_factory = RingCentralSdk::PubnubFactory.new(use_pubnub_mock)
    end

    def request(helper=nil)
      return @platform.request(helper)
    end

    def create_subscription()
      return RingCentralSdk::Subscription.new(@platform, @_pubnub_factory)
    end
  end
end