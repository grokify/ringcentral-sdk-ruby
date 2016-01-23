module RingCentralSdk::REST
  class SimpleClient
    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def send(request)
      if request.is_a?(RingCentralSdk::Helpers::Request)
        return @client.request(request)
      elsif ! request.is_a?(Hash)
        raise "Request is not a RingCentralSdk::Helpers::Request or Hash"
      end

      verb = request.has_key?(:verb) ? request[:verb].to_s.downcase : 'get'

      if verb == 'get'
        return get(request)
      elsif verb == 'post'
        return post(request)
      elsif verb == 'put'
        return put(request)
      elsif verb == 'delete'
        return delete(request)
      else
        raise 'Method not supported'
      end
    end

    def delete(opts={})
      return @client.http.delete do |req|
        req.url build_url(opts[:path])
      end
    end

    def get(opts={})
      return @client.http.get do |req|
        req.url build_url(opts[:path])
      end
    end

    def post(opts={})
      return @client.http.post do |req|
        req.url build_url(opts[:path])
        if opts.has_key?(:body)
          req.body = opts[:body]
          if opts[:body].is_a?(Hash)
            req.headers['Content-Type'] = 'application/json'
          end
        end
      end
    end

    def put(opts={})
      return @client.http.put do |req|
        req.url build_url(opts[:path])
        if opts.has_key?(:body)
          req.body = opts[:body]
          if opts[:body].is_a?(Hash)
            req.headers['Content-Type'] = 'application/json'
          end
        end
      end
    end

    def build_url(path)
      url = ''
      if !path.is_a?(Array)
        path = [path]
      end
      if path.length>0
        path0 = path[0].to_s
        if path0 !~ /\//
          if path0.index('account') != 0
            if path0.index('extension') != 0
              path.unshift('extension/~')
            end
            path.unshift('account/~')
          end
        end
      end
      url = path.join('/')
      return url
    end

  end
end
