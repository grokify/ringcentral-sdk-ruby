require 'jsondoc'
require 'multi_json'

require 'pp'

module RingCentralSdk::REST
  class Event
    attr_accessor :doc
    def initialize(data={}, opts={})
      if data.is_a? JsonDoc::Document
        @doc = data
      elsif data.is_a? Hash
        data = _symbolize_keys data
        @doc = JsonDoc::Document.new(data,false, false, false)
      elsif opts.key?(:force) && opts[:force]
        @doc = JsonDoc::Document.new({}, false, false, false)
      else
        raise 'initialize needs JsonDoc::Document or Hash argument'
      end
    end

    def _hash_has_string_keys(hash={})
      hash.each do |k,v|
        return true if k.is_a? String
      end
      return false
    end

    def _symbolize_keys(hash={})
      if _hash_has_string_keys hash
        return MultiJson.decode(MultiJson.encode(hash), :symbolize_keys=>true)
      end
      return hash
    end

    def new_sms_count()
      count = 0
      have_sms = false
      changes = @doc.getAttr('body.changes')

puts '---'
      pp changes
puts '==='
      if changes.is_a?(Array) && changes.length > 0
        changes.each do |change|
          if change.key?(:type) && change[:type].to_s.downcase == 'sms'
            have_sms = true
            if change.key?(:newCount)
              count += change[:newCount]
            end
          end
        end
      end
      return have_sms ? count : -1
    end

    private :_hash_has_string_keys, :_symbolize_keys
  end
end
