require 'base64'
require 'mime'
require 'mime/types'
require 'mime_builder'
require 'multi_json'

module RingCentralSdk
  module REST
    module Request
      class SMS < RingCentralSdk::REST::Request::Base
        CONTENT_ID_HEADER = 'Content-Id'
        DEFAULT_METHOD = 'post'
        DEFAULT_ID = '~'
        DEFAULT_BASE64_ENCODE = true
        DEFAULT_CONTENT_ID_DISABLE = true

        attr_accessor :method
        attr_accessor :mime_part_params

        attr_reader :mime
        attr_reader :account_id
        attr_reader :extension_id

        def initialize(opts = {})
          @mime = MIME::Multipart::Mixed.new
          @mime.headers.delete CONTENT_ID_HEADER

          @method = opts[:method] ||= DEFAULT_METHOD

          @mime_part_params = {
            base64_encode: opts[:base64_encode] ||= DEFAULT_BASE64_ENCODE,
            content_id_disable: opts[:content_id_disable] ||= DEFAULT_CONTENT_ID_DISABLE
          }

          path_params(opts)
        end

        def path_params(opts = {})
          @account_id = opts[:account_id] ||= DEFAULT_ID
          @extension_id = opts[:extension_id] ||= DEFAULT_ID
        end

        def add_metadata(data, opts = {})
          if data.is_a? Hash
            inf = RingCentralSdk::REST::Request::Inflator::ContactInfo.new
            if data.key? :to
              data[:to] = inf.inflate_to_array data[:to]
            end
            if data.key? :from
              data[:from] = inf.inflate_to_object data[:from]
            end
          end

          @mime.add MIMEBuilder::JSON.new(
            data,
            @mime_part_params.merge(opts)
          ).mime
        end

        def add_file(filepath, opts = {})
          @mime.add MIMEBuilder::Filepath.new(
            filepath,
            @mime_part_params.merge(opts).merge({is_attachment: true})
          ).mime
        end

        def url
          "account/#{@account_id}/extension/#{@extension_id}/sms"
        end

        def content_type
          @mime.headers.get('Content-Type').to_s
        end

        def body
          @mime.body.to_s
        end
      end
    end
  end
end
