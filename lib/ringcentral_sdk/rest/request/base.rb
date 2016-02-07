module RingCentralSdk::REST::Request
  class Base
    def method
      return 'get' # HTTP methods
    end

    def url
      return ''
    end

    def params
      return {}
    end

    def headers
      return {}
    end

    def content_type
      return ''
    end

    def body
      return '' # '' || Hash
    end
  end
end
