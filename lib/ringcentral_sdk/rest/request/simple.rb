module RingCentralSdk::REST::Request
  class Simple < RingCentralSdk::REST::Request::Base
    def initialize(opts = {})
      @method = opts[:method]
      @url = opts[:url]
      @params = opts[:params]
      @headers = opts[:headers]
      @body = opts[:body].nil? ? {} : opts[:body]
      if @body.is_a? Hash 
        @headers = {} unless @headers.is_a? Hash 
        @headers['Content-Type'] = 'application/json'
      end

      def content_type
        ct = @headers.is_a?(Hash) \
          ? @headers['Content-Type'] || '' : 'application/json'
      end

      def method
        @method
      end

      def url
        @url
      end

      def params
        @params
      end

      def headers
        @headers
      end

      def body
        @body
      end
    end
  end
end
