module RingCentralSdk::REST
  class Messages
    attr_reader :sms
    attr_reader :fax

    def initialize(client)
      @client = client
      @sms = RingCentralSdk::REST::MessagesSMS.new(client)
      @fax = RingCentralSdk::REST::MessagesFax.new(client)
    end
  end
end

module RingCentralSdk::REST
  class MessagesSMS
    def initialize(client)
      @client = client
    end

    def create(opts)
      response = @client.http.post do |req|
        req.url 'account/~/extension/~/sms'
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          from: { :phoneNumber => opts[:from].to_s },
          to: [ { :phoneNumber => opts[:to].to_s } ],
          text: opts[:text].to_s
        }
      end
      return response
    end
  end
end

module RingCentralSdk::REST
  class MessagesFax
    def initialize(client)
      @client = client
    end

    def create(opts)
      fax = RingCentralSdk::REST::Request::Fax.new(opts)
      return @client.send_request(fax)
    end
  end
end
