module RingCentralSdk::REST::Request
  class Base
    def method()
      return 'get'
    end
    def url()
      return ''
    end
    def content_type()
      return ''
    end
    def body()
      return ''
    end
  end
end