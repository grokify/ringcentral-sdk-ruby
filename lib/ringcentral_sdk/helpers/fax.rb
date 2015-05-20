require 'base64'
require 'mime'
require 'mime/types'
require 'multi_json'

module RingCentralSdk::Helpers
  class CreateFaxRequest < RingCentralSdk::Helpers::Request
    attr_reader :msg

    def initialize(path_params=nil,metadata=nil,options=nil)

      @msg = MIME::Multipart::Mixed.new
      @msg.headers.delete('Content-Id')

      @path_params = path_params

      if metadata.is_a?(Hash) || metadata.is_a?(String)
        add_metadata(metadata)
      end

      if options.is_a?(Hash)
        if options.has_key?(:file_name)
          if options.has_key?(:base64_encode) && options[:base64_encode]
            add_file_base64(options[:file_name],options[:file_content_type])
          else
            add_file_octet_stream(options[:file_name])
          end
        elsif options.has_key?(:text)
          add_file_text(options[:text])
        end
      end
    end

    def add_metadata(meta=nil)
      meta = inflate_metadata(meta)
      json = MultiJson.encode(meta)
      if json.is_a?(String)
        json_part = MIME::Text.new(json)
        json_part.headers.delete('Content-Id')
        json_part.headers.set('Content-Type','application/json')
        @msg.add(json_part)
        return true
      end
      return false
    end

    def inflate_metadata(meta=nil)
      if meta.is_a?(String)
        meta = MultiJson.decode(meta,:symbolize_keys=>true)
      end
      if meta.is_a?(Hash)
        inf = RingCentralSdk::Helpers::Inflator::ContactInfo.new

        if meta.has_key?(:to)
          meta[:to] = inf.inflate_to_array( meta[:to] )
        elsif meta.has_key?("to")
          meta["to"] = inf.inflate_to_array( meta["to"] )
        else
          meta[:to] = inf.inflate_to_array( nil )
        end
      end
      return meta
    end

    def add_file_text(text=nil,charset='UTF-8')
      return unless text.is_a?(String)
      text_part = MIME::Text.new(text,'plain')
      text_part.headers.delete('Content-Id')
      @msg.add(text_part)
    end

    def add_file_base64(file_name=nil,content_type=nil)
      unless file_name.is_a?(String) && File.file?(file_name)
        return false
      end

      content_type = (content_type.is_a?(String) && content_type =~ /^[^\/\s]+\/[^\/\s]+/) \
        ? content_type : MIME::Types.type_for(file_name).first.content_type

      base_name   = File.basename(file_name)
      file_base64 = Base64.encode64(File.binread(file_name))

      base64_part = MIME::Text.new(file_base64)
      base64_part.headers.delete('Content-Id')
      base64_part.headers.set('Content-Type', content_type)
      base64_part.headers.set('Content-Transfer-Encoding','base64')
      if base_name.is_a?(String) && base_name.length>0
        base64_part.headers.set('Content-Disposition', "attachment; filename=\"#{base_name}\"")
      else
        base64_part.headers.set('Content-Disposition', 'attachment')
      end

      @msg.add(base64_part)
      return true
    end

    def add_file_octet_stream(file_name=nil)
      unless file_name.is_a?(String) && File.file?(file_name)
        return false
      end

      content_type = (content_type.is_a?(String) && content_type =~ /^[^\/\s]+\/[^\/\s]+/) \
        ? content_type : MIME::Types.type_for(file_name).first.content_type

      base_name  = File.basename(file_name)
      file_bytes = File.binread(file_name)

      file_part  = MIME::Application.new(file_bytes)
      file_part.headers.delete('Content-Id')
      file_part.headers.set('Content-Type', content_type)
      if base_name.is_a?(String) && base_name.length>0
        file_part.headers.set('Content-Disposition', "attachment; filename=\"#{base_name}\"")
      else
        file_part.headers.set('Content-Disposition', 'attachment')
      end

      @msg.add(file_part)
      return true
    end

    def method()
      return 'post'
    end

    def url()
      account_id   = "~"
      extension_id = "~"
      if @path_params.is_a?(Hash)
        if @path_params.has_key?(:account_id)
          if @path_params[:account_id].is_a?(String) && @path_params[:account_id].length>0
            account_id = @path_params[:account_id]
          elsif @path_params[:account_id].is_a?(Integer) && @path_params[:account_id]>0
            account_id = @path_params[:account_id].to_s
          end
        end
        if @path_params.has_key?(:extension_id)
          if @path_params[:extension_id].is_a?(String) && @path_params[:extension_id].length>0
            extension_id = @path_params[:extension_id]
          elsif @path_params[:extension_id].is_a?(Integer) && @path_params[:extension_id]>0
            extension_id = @path_params[:extension_id].to_s
          end
        end
      end
      url = "account/#{account_id.to_s}/extension/#{extension_id.to_s}/fax"
      return url
    end

    def content_type()
      return @msg.headers.get('Content-Type').to_s
    end

    def body()
      return @msg.body.to_s
    end

    # Experimental
    def _add_file(file_name=nil)
      if file_name.is_a?(String) && File.file?(file_name)
        file_msg = MIME::DiscreteMediaFactory.create(file_name)
        file_msg.headers.delete('Content-Id')
        @msg.add(file_msg)
        return true
      end
      return false
    end
    private :_add_file
  end
end