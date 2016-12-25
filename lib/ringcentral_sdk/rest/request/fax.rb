require 'base64'
require 'mime'
require 'mime/types'
require 'mime_builder'
require 'multi_json'

module RingCentralSdk
  module REST
    module Request
      # Helper to create a fax request
      class Fax < RingCentralSdk::REST::Request::Base
        attr_reader :msg

        attr_reader :account_id
        attr_reader :extension_id

        def initialize(opts = {})
          @metadata_part_encode_base64 = true

          @msg = MIME::Multipart::Mixed.new
          @msg.headers.delete('Content-Id')

          add_path(opts)
          add_part_meta(opts)
          add_part_text(opts[:text])
          add_parts(opts[:files])
          add_parts(opts[:parts])
        end

        def add_path(opts = {})
          @account_id = opts[:accountId] ||= '~'
          @extension_id = opts[:extensionId] ||= '~'
        end

        def add_part_meta(opts = {})
          meta = create_metadata opts
          @msg.add MIMEBuilder::JSON.new(meta).mime
          true
        end

        def create_metadata(opts = {})
          meta = {}
          return meta unless opts.is_a?(Hash)

          inf = RingCentralSdk::REST::Request::Inflator::ContactInfo.new
          meta[:to] = inf.inflate_to_array opts[:to]

          processed = {
            accountId: 1,
            extensionId: 1,
            to: 1,
            text: 1,
            files: 1,
            parts: 1
          }

          opts.each do |k, v|
            meta[k] = v unless processed.key? k
          end

          meta
        end

        def add_part_text(text = nil, opts = {})
          return if text.nil? || text.to_s.empty?
          opts[:content_id_disable] = true
          text_part = MIMEBuilder::Text.new text, opts
          @msg.add text_part.mime
        end

        def add_parts(parts = [])
          return if parts.nil?
          unless parts.is_a? Array
            raise 'invalid parameter[0]. needs to be an array'
          end
          parts.each do |part|
            if part.is_a? MIME::Media
              @msg.add part
            elsif part.is_a?(String)
              file_part = MIMEBuilder::Filepath.new part
              @msg.add file_part.mime
            elsif part.is_a? Hash
              part[:content_id_disable] = true
              part[:is_attachment] = true
              if part.key? :filename
                @msg.add MIMEBuilder::Filepath.new(part[:filename], part).mime
              elsif part.key? :text
                @msg.add MIMEBuilder::Text.new(part[:text], part).mime
              end
            end
          end
        end

        def method
          'post'
        end

        def url
          "account/#{@account_id}/extension/#{@extension_id}/fax"
        end

        def content_type
          @msg.headers.get('Content-Type').to_s
        end

        def body
          @msg.body.to_s
        end
      end
    end
  end
end
