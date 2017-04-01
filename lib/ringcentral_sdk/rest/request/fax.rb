module RingCentralSdk
  module REST
    module Request
      class Fax < RingCentralSdk::REST::Request::BaseMultipart
        def add_metadata data, opts = {}
          if data.is_a? Hash
            inf = RingCentralSdk::REST::Request::Inflator::ContactInfo.new
            if data.key? :to
              data[:to] = inf.inflate_to_array data[:to]
            end
          end

          super data, opts
        end

        def url
          "account/#{@account_id}/extension/#{@extension_id}/fax"
        end
      end
    end
  end
end
