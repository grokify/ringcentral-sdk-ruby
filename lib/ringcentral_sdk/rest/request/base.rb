module RingCentralSdk
  module REST
    module Request
      class Base
        def method
          'get' # HTTP methods
        end

        def url
          ''
        end

        def params
          {}
        end

        def headers
          {}
        end

        def content_type
          ''
        end

        def body
          '' # '' || Hash
        end
      end
    end
  end
end
