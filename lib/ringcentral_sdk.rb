# RingCentralSdk is a SDK for the RingCentral REST API
module RingCentralSdk
  VERSION = '2.3.0'.freeze

  RC_SERVER_PRODUCTION = 'https://platform.ringcentral.com'.freeze
  RC_SERVER_SANDBOX = 'https://platform.devtest.ringcentral.com'.freeze

  autoload :REST, 'ringcentral_sdk/rest'
end
