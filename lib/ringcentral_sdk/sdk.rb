module RingCentralSdk
  class Sdk

    RC_SERVER_PRODUCTION = 'https://platform.ringcentral.com'
    RC_SERVER_SANDBOX    = 'https://platform.devtest.ringcentral.com'

    attr_reader :parser
    attr_reader :platform

    def initialize(app_key=nil,app_secret=nil,server_url=nil)
      @parser   = RingCentralSdk::Platform::Parser.new
      @platform = RingCentralSdk::Platform::Platform.new(app_key, app_secret, server_url)
    end
  end
end
