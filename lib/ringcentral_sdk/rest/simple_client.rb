module RingCentralSdk
  module REST
    # A simplified, but still generic, REST interface.
    #
    # NOTE: This is an experimental module.
    #
    # client = RingCentralSdk::REST::Client.new ...
    # simple = RingCentralSdk::REST::SimpleClient client
    #
    # simple.post(
    #   path: 'sms',
    #   body: {
    #     from: {phoneNumber: '+16505551212'},
    #     to: [{phoneNumber: '+14155551212'}],
    #     text: 'Hi There!'
    #   }
    # )
    class SimpleClient
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      def send(request)
        return @client.request(request) if request.is_a? RingCentralSdk::Helpers::Request
        raise(ArgumentError, 'Request is not a ...Helpers::Request or Hash') unless request.is_a? Hash

        verb = request.key?(:verb) ? request[:verb].to_s.downcase : 'get'

        return get(request) if verb == 'get'
        return post(request) if verb == 'post'
        return put(request) if verb == 'put'
        return delete(request) if verb == 'delete'
        raise  ArgumentError, "Method not supported #{verb}"
      end

      def delete(opts = {})
        @client.http.delete do |req|
          req.url build_url(opts[:path])
        end
      end

      def get(opts = {})
        @client.http.get do |req|
          req.url build_url(opts[:path])
        end
      end

      def post(opts = {})
        @client.http.post do |req|
          req = inflate_request req, opts
        end
      end

      def put(opts = {})
        @client.http.put do |req|
          req = inflate_request req, opts
        end
      end

      def inflate_request(req, opts = {})
        req.url build_url(opts[:path])
        if opts.key? :body
          req.body = opts[:body]
          if opts[:body].is_a?(Hash)
            req.headers['Content-Type'] = 'application/json'
          end
        end
        req
      end

      def build_url(path)
        path = [path] unless path.is_a? Array

        unless path.empty?
          path0 = path[0].to_s
          if path0.index('/').nil? && path0.index('account') != 0
            path.unshift('extension/~') if path0.index('extension') != 0
            path.unshift('account/~')
          end
        end
        path.join('/')
      end
    end
  end
end
