require 'base64'
require 'mime'
require 'mime/types'
require 'multi_json'

module RingCentralSdk::Helpers
  class CreateFaxRequest < RingCentralSdk::Helpers::Request
    attr_reader :msg

    def initialize(path_params=nil, metadata=nil, options=nil)

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
      json_part = MIME::Text.new(json)
      json_part.headers.delete('Content-Id')
      json_part.headers.set('Content-Type','application/json')
      @msg.add(json_part)
      return true
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
      file_part = get_file_part(file_name, content_type, base64_encode)

      @msg.add(file_part)
      return true
    end

    def get_file_part(file_name=nil, content_type=nil, base64_encode=false)

      file_bytes = get_file_bytes(file_name)

      file_part  = base64_encode \
        ? MIME::Text.new(Base64.encode64(file_bytes)) \
        : MIME::Application.new(file_bytes)

      file_part.headers.delete('Content-Id')
      file_part.headers.set('Content-Type', get_file_content_type(file_name, content_type))
      file_part.headers.set('Content-Disposition', get_attachment_content_disposition(file_name))
      file_part.headers.set('Content-Transfer-Encoding', 'base64') if base64_encode
      return file_part
    end

    def get_file_bytes(file_name=nil)

      unless File.file?(file_name.to_s)
        raise "File \"#{file_name.to_s}\" does not exist or cannot be read"
      end

      file_bytes = RUBY_VERSION < '1.9' \
        ? File.open(file_name, 'rb')        { |f| f.read } \
        : File.open(file_name, 'rb:BINARY') { |f| f.read }

      return file_bytes

    end

    def get_file_content_type(file_name=nil, content_type=nil)
      return (content_type.is_a?(String) && content_type =~ /^[^\/\s]+\/[^\/\s]+/) \
        ? content_type : MIME::Types.type_for(file_name).first.content_type || 'application/octet-stream'
    end

    def get_attachment_content_disposition(file_name=nil)
      base_name = File.basename(file_name.to_s)
      if base_name.is_a?(String) && base_name.length>0
        return "attachment; filename=\"#{base_name}\""
      else
        return 'attachment'
      end
    end

    def method()
      return 'post'
    end

    def url()

      vals = {:account_id => '~', :extension_id => '~'}

      if @path_params.is_a?(Hash)
        vals.keys.each do |key|
          next unless @path_params.has_key?(key)
          if @path_params[key].is_a?(String) && @path_params[key].length>0
            vals[key] = @path_params[key]
          elsif @path_params[key].is_a?(Integer) && @path_params[key]>0
            vals[key] = @path_params[key].to_s
          end
        end
      end

      return "account/#{vals[:account_id].to_s}/extension/#{vals[:extension_id].to_s}/fax"

    end

    def content_type()
      return @msg.headers.get('Content-Type').to_s
    end

    def body()
      return @msg.body.to_s
    end

    # Experimental
    #def _add_file(file_name=nil)
    #  if file_name.is_a?(String) && File.file?(file_name)
    #    file_msg = MIME::DiscreteMediaFactory.create(file_name)
    #    file_msg.headers.delete('Content-Id')
    #    @msg.add(file_msg)
    #    return true
    #  end
    #  return false
    #end
    #private :_add_file
  end
end