module RingCentralSdk
  class Sdk

    RC_SERVER_PRODUCTION = 'https://platform.ringcentral.com'
    RC_SERVER_SANDBOX    = 'https://platform.devtest.ringcentral.com'

    attr_reader :parser
    attr_reader :platform

    def initialize(app_key=nil,app_secret=nil,server_url=nil,username=nil,extension=nil,password=nil)
      @parser   = RingCentralSdk::Platform::Parser.new
      @platform = RingCentralSdk::Platform::Platform.new(app_key, app_secret, server_url)
      if not username.nil? and not password.nil?
        @platform.authorize(username, extension, password)
      end
    end

    def request(helper=nil)
      return @platform.request(helper)
    end
  end
end
