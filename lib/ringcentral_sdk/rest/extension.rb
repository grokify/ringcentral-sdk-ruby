module RingCentralSdk::REST
  class Extension
  	attr_reader :extension_id
  	attr_reader :presence
  	attr_accessor :client
  	def initialize(extension_id, opts={})
  	  @extension_id = extension_id
  	  @client = opts.has_key?(:client) ? opts[:client] : nil
      @presence = RingCentralSdk::REST::ExtensionPresence.new(extension_id, opts)
  	end
  end
end
