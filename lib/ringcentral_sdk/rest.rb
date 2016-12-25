module RingCentralSdk
  # REST is the namespace for the RingCentral REST API class in the
  # RingCentral Ruby SDK
  module REST
    autoload :Cache, 'ringcentral_sdk/rest/cache'
    autoload :Client, 'ringcentral_sdk/rest/client'
    autoload :Configuration, 'ringcentral_sdk/rest/configuration'
    autoload :Event, 'ringcentral_sdk/rest/event'
    autoload :Extension, 'ringcentral_sdk/rest/extension'
    autoload :ExtensionPresence, 'ringcentral_sdk/rest/extension_presence'
    autoload :Messages, 'ringcentral_sdk/rest/messages'
    autoload :MessagesFax, 'ringcentral_sdk/rest/messages'
    autoload :MessagesSMS, 'ringcentral_sdk/rest/messages'
    autoload :MessagesRetriever, 'ringcentral_sdk/rest/messages_retriever'
    autoload :Request, 'ringcentral_sdk/rest/request'
    autoload :SimpleClient, 'ringcentral_sdk/rest/simple_client'
    autoload :Subscription, 'ringcentral_sdk/rest/subscription'
  end
end
