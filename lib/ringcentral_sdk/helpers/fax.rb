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
          add_file(options[:file_name], options[:file_content_type], options[:base64_encode])
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

    def add_file_text(text=nil, charset='UTF-8')
      return unless text.is_a?(String)
      text_part = MIME::Text.new(text,'plain')
      text_part.headers.delete('Content-Id')
      @msg.add(text_part)
    end

    def add_file(file_name=nil, content_type=nil, base64_encode=false)
      unless File.file?(file_name.to_s)
        raise "File \"#{file_name.to_s}\" does not exist or cannot be read"
      end

      content_type = (content_type.is_a?(String) && content_type =~ /^[^\/\s]+\/[^\/\s]+/) \
        ? content_type : MIME::Types.type_for(file_name).first.content_type || 'application/octet-stream'

      file_part  = base64_encode \
        ? MIME::Text.new(Base64.encode64(File.binread(file_name))) \
        : MIME::Application.new(File.binread(file_name))
      
      file_part.headers.delete('Content-Id')
      file_part.headers.set('Content-Type', content_type)

      # Add file name
      base_name  = File.basename(file_name)
      if base_name.is_a?(String) && base_name.length>0
        file_part.headers.set('Content-Disposition', "attachment; filename=\"#{base_name}\"")
      else
        file_part.headers.set('Content-Disposition', 'attachment')
      end

      # Base64 Encoding
      if base64_encode
        file_part.headers.set('Content-Transfer-Encoding','base64')
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