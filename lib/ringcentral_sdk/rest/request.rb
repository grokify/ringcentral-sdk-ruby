module RingCentralSdk
  module REST
  	# Request is the module namespace for various API request helpers.
    module Request
      autoload :Base, 'ringcentral_sdk/rest/request/base'
      autoload :Fax, 'ringcentral_sdk/rest/request/fax'
      autoload :Inflator, 'ringcentral_sdk/rest/request/inflator'
      autoload :Simple, 'ringcentral_sdk/rest/request/simple'
    end
  end
end
