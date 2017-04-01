require 'base64'
require 'mime'
require 'mime/types'
require 'mime_builder'
require 'multi_json'

module RingCentralSdk
  module REST
    module Request
      # BaseMultipart is a base reqwuest helper class for multipart/mixed messages
      class BaseMultipart < RingCentralSdk::REST::Request::Base
        CONTENT_ID_HEADER = 'Content-Id'.freeze
        DEFAULT_METHOD = 'post'.freeze
        DEFAULT_ID = '~'.freeze
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
          @account_id = opts[:account_id] ||= opts[:accountId] ||= DEFAULT_ID
          @extension_id = opts[:extension_id] ||= opts[:extensionId] ||= DEFAULT_ID
        end

        def add_metadata(data, opts = {})
          if data.is_a? MIME::Media
            @mime.add data
          else
            @mime.add MIMEBuilder::JSON.new(
              data,
              @mime_part_params.merge(opts)
            ).mime
          end
        end

        def add_text(text = nil, opts = {})
          return if text.nil? || text.to_s.empty?
          @mime.add MIMEBuilder::Text.new(
            text,
            @mime_part_params.merge(opts)
          ).mime
        end

        def add_file(file_path_or_part, opts = {})
          if file_path_or_part.is_a? MIME::Media
            @mime.add file_path_or_part
          else
            @mime.add MIMEBuilder::Filepath.new(
              file_path_or_part,
              @mime_part_params.merge(opts).merge({is_attachment: true})
            ).mime
          end
        end

        def add_files(files = [], opts = {})
          files.each do |f|
            add_file f, opts
          end
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
