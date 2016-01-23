require 'base64'
require 'mime'
require 'mime/types'
require 'mime_builder'
require 'multi_json'

module RingCentralSdk::REST::Request
  class Fax < RingCentralSdk::REST::Request::Base
    attr_reader :msg

    attr_reader :account_id
    attr_reader :extension_id

    def initialize(opts={})
      @metadata_part_encode_base64 = true

      @msg = MIME::Multipart::Mixed.new
      @msg.headers.delete('Content-Id')

      add_path(opts)
      add_part_meta(opts)
      add_part_text(opts[:text])
      add_parts(opts[:files])
      add_parts(opts[:parts])
    end

    def add_path(opts={})
      if opts.has_key?(:accountId) && opts[:accountId].to_s.length>0
        @account_id = opts[:accountId]
      else
        @account_id = '~'
      end
      if opts.has_key?(:extensionId) && opts[:extensionId].to_s.length>0
        @extension_id = opts[:extensionId]
      else
        @extension_id = '~'
      end
    end

    def add_part_meta(opts={})
      meta = create_metadata opts
      json = MultiJson.encode meta
      json = Base64.encode64(json) if @metadata_part_encode_base64
      json_part = MIME::Text.new(json)
      json_part.headers.delete('Content-Id')
      json_part.headers.set('Content-Type', 'application/json')
      json_part.headers.set('Content-Transfer-Encoding', 'base64') if @metadata_part_encode_base64
      @msg.add(json_part)
      return true
    end

    def create_metadata(opts={})
      meta = {}
      return meta unless opts.is_a?(Hash)

      inf = RingCentralSdk::REST::Request::Inflator::ContactInfo.new
      meta[:to] = inf.inflate_to_array opts[:to]

      processed = {
        :accountId => 1,
        :extensionId => 1,
        :to    => 1,
        :text  => 1,
        :files => 1,
        :parts => 1
      }

      opts.each do |k,v|
        meta[k] = v unless processed.has_key?(k)
      end

      return meta
    end

    def add_part_text(text=nil, opts={})
      return unless !text.nil? && text.to_s.length>0
      opts[:content_id_disable] = true
      text_part = MIMEBuilder::Text.new(text, opts)
      @msg.add(text_part.mime)
    end

    def add_parts(parts=[])
      return if parts.nil?
      unless parts.is_a?(Array)
        raise 'invalid parameter[0]. needs to be an array'
      end
      parts.each do |part|
        if part.is_a?(String)
          file_part = MIMEBuilder::Filepath.new(part)
          @msg.add(file_part.mime)
        elsif part.is_a?(Hash)
          part[:content_id_disable] = true
          part[:is_attachment] = true
          if part.has_key(:filename)
            file_part = MIMEBuilder::Filepath.new(part[:filename], part)
            @msg.add(file_part.mime)
          elsif part.has_key?(:text)
            text_part = MIMEBuilder::Text.new(part[:text], part)
            @msg.add(text_part.mime)
          end
        end
      end
    end

    def method()
      return 'post'
    end

    def url()
      return "account/#{@account_id.to_s}/extension/#{@extension_id.to_s}/fax"
    end

    def content_type()
      return @msg.headers.get('Content-Type').to_s
    end

    def body()
      return @msg.body.to_s
    end

  end
end