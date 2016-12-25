require 'date'
require 'jsondoc'

module RingCentralSdk
  module REST
    class MessagesRetriever
      attr_accessor :range
      def initialize(client)
        @client = client
        @range = 1.0 # minutes
      end

      def retrieve_for_event(event, params={})
        unless event.is_a? RingCentralSdk::REST::Event
          fail 'retrieve_for_event requires RingCentralSdk::REST::Event argument'
        end
        url = event.doc.getAttr :event
        last_updated_s = event.doc.getAttr('body.lastUpdated')
        last_updated_dt = DateTime.iso8601(last_updated_s)

        params.merge!(
          dateFrom: (last_updated_dt - (@range/1440.0)).to_s,
          dateTo: (last_updated_dt + (@range/1440.0)).to_s)
        
        if event.new_sms_count > 0
          params[:messageType] = 'SMS'
        end

        res = @client.http.get do |req|
          req.url url
          req.params = params
        end

        messages = []

        res.body['records'].each do |rec|
          rec_last_modified_time = rec['lastModifiedTime']
          rec_last_modified_time_dt = DateTime.iso8601(rec_last_modified_time)
          if rec_last_modified_time_dt == last_updated_dt
            messages.push rec
          end
        end
        return messages
      end
    end
  end
end
