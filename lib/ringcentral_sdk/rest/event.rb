require 'jsondoc'
require 'multi_json'

module RingCentralSdk
  module REST
    # Event represents a Subscription API event
    class Event
      attr_accessor :doc
      def initialize(data = nil)
        if data.is_a? JsonDoc::Document
          @doc = data
        elsif data.is_a? Hash
          data = _symbolize_keys data
          @doc = JsonDoc::Document.new(data, false, false, false)
        elsif data.nil?
          @doc = JsonDoc::Document.new({}, false, false, false)
        else
          raise 'initialize needs JsonDoc::Document or Hash argument'
        end
      end

      def _hash_has_string_keys(hash = {})
        hash.each do |k, _|
          return true if k.is_a? String
        end
        false
      end

      def _symbolize_keys(hash = {})
        if _hash_has_string_keys hash
          return MultiJson.decode(MultiJson.encode(hash), symbolize_keys: true)
        end
        hash
      end

      def new_fax_count
        new_type_count('fax')
      end

      def new_sms_count
        new_type_count('sms')
      end

      def new_type_count(type)
        count = 0
        have_type = false
        changes = @doc.getAttr('body.changes')
        if changes.is_a?(Array) && !changes.empty?
          changes.each do |change|
            if change.key?(:type) && change[:type].to_s.downcase == type
              have_type = true
              count += change[:newCount] if change.key? :newCount
            end
          end
        end
        have_type ? count : -1
      end

      private :_hash_has_string_keys, :_symbolize_keys
    end
  end
end
