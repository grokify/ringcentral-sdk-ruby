module RingCentralSdk
  module REST
    # Cache is the namespace module for various cache classes such as
    # the Extensions cache class.
    module Cache
      autoload :Extensions, 'ringcentral_sdk/rest/cache/extensions'
    end
  end
end
