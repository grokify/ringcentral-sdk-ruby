module RingCentralSdk
  module REST
    module Request
      class SMS < RingCentralSdk::REST::Request::BaseMultipart
        def add_metadata data, opts = {}
          if data.is_a? Hash
            inf = RingCentralSdk::REST::Request::Inflator::ContactInfo.new
            if data.key? :to
              data[:to] = inf.inflate_to_array data[:to]
            end
            if data.key? :from
              data[:from] = inf.inflate_to_object data[:from]
            end
          end

          super data, opts
        end

        def url
          "account/#{@account_id}/extension/#{@extension_id}/sms"
        end
      end
    end
  end
end
