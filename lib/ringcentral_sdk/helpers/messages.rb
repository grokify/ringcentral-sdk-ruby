module RingCentralSdk::Helpers
  class Messages
    def initialize(rcapi)
      @rcapi = rcapi
    end
    def create(opts)
      response = @rcapi.client.post do |req|
        req.url 'account/~/extension/~/sms'
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          :from =>   { :phoneNumber => opts[:from].to_s },
          :to   => [ { :phoneNumber => opts[:to].to_s } ],
          :text => opts[:text].to_s
        }
      end
      return response
    end
  end
end