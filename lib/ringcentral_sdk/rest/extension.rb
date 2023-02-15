module RingCentralSdk
  module REST
    # Extension represents a RingCentral user extension object
    class Extension
      attr_reader :extension_id
      attr_reader :presence
      attr_accessor :client
      def initialize(extension_id, opts = {})
        @extension_id = extension_id
        @client = opts.key?(:client) ? opts[:client] : nil
        @presence = RingCentralSdk::REST::ExtensionPresence.new(extension_id, opts)
      end
    end
  end
end
