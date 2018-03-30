module RingCentralSdk
  module REST
    # Messages is a wrapper helper class
    class Messages
      attr_reader :sms
      attr_reader :fax

      def initialize(client)
        @client = client
        @sms = RingCentralSdk::REST::MessagesSMS.new client
        @fax = RingCentralSdk::REST::MessagesFax.new client
      end
    end
  end
end

module RingCentralSdk
  module REST
    # MessagesSMS provides a helper for SMS and MMS messages
    class MessagesSMS
      def initialize(client)
        @client = client
      end

      def create(opts)
        req = RingCentralSdk::REST::Request::SMS.new
        req.add_metadata({
          to:   opts[:to],
          from: opts[:from],
          text: opts[:text]
        })
        if opts.key? :media
          if opts[:media].is_a? String
            req.add_file opts[:media]
          elsif opts[:media].is_a? Array
            req.add_files opts[:media]
          end
        end
        @client.send_request req
      end
    end
  end
end

module RingCentralSdk
  module REST
    # MessagesFax provides a helper for fax requests
    class MessagesFax
      def initialize(client)
        @client = client
      end

      def create(opts)
        req  = RingCentralSdk::REST::Request::Fax.new
        meta = {}

        skip = {text: 1, files: 1}

        opts.each do |k,v|
          meta[k] = v unless skip.key? k
        end

        req.add_metadata meta

        if opts.key? :text
          req.add_text opts[:text]
        end

        if opts.key? :files
          if opts[:files].is_a? String
            req.add_file opts[:files]
          elsif opts[:files].is_a? Array
            req.add_files opts[:files]
          end
        end
        @client.send_request req
      end
    end
  end
end
