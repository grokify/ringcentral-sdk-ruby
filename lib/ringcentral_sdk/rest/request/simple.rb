module RingCentralSdk::REST::Request
  class Simple < RingCentralSdk::REST::Request::Base
    attr_reader :method
    attr_reader :url
    attr_reader :params
    attr_reader :headers
    attr_reader :body

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
    end
  end
end
