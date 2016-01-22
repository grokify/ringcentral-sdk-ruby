require 'time'
require 'uri'

module RingCentralSdk::Cache
  class Extensions

    attr_accessor :rc_api
    attr_reader :extensions_hash
    attr_reader :extensions_num2id
    attr_reader :last_retrieved

    def initialize(rc_api)
      @rc_api = rc_api
      @extensions_hash = {}
      @extensions_num2id = {}
      @last_retrieved = -1
    end

    def retrieve(url='account/~/extension', params={}, retrieve_all=true)
      @last_retrieved = Time.now.to_i
      uri = URI.parse(url)
      if params.length > 0 
        uri.query = URI.encode_www_form(params)
      end
      res = @rc_api.client.get do |req|
        req.url uri.to_s
        if retrieve_all
          req.params['page'] = 1
          req.params['perPage'] = 1000
        end
      end
      res.body['records'].each do |extension|
        if extension.has_key?('id') && extension['id']>0
          @extensions_hash[extension['id'].to_s] = extension
        end
      end
      if retrieve_all
        while res.body.has_key?('navigation') && res.body['navigation'].has_key?('nextPage')
          res = rcsdk.client.get do |req|
            req.url res.body['navigation']['nextPage']['uri']
          end
          res.body['records'].each do |record|
            if extension.has_key?('id') && extension['id'].length>0
              @extensions_hash[extension['id'].to_s] = extension
            end
          end
        end
      end
      inflate_num2id()
      return @extensions_hash
    end

    def retrieve_all()
      retrieve('account/~/extension', {}, true)
    end

    def inflate_num2id()
      num2id = {}
      @extensions_hash.each do |k,v|
        if v.has_key?('id') && v['id']>0 &&
          v.has_key?('extensionNumber') && v['extensionNumber'].length>0
          num2id[v['extensionNumber']] = v['id'].to_s
        end
      end
      @extensions_num2id = num2id
      return num2id
    end

    def get_extension_by_id(extension_id)
      if !extension_id.is_a?(String)
        extension_id = extension_id.to_s
      end
      if @extensions_hash.has_key?(extension_id)
          return @extensions_hash[extension_id]
      end
      return nil
    end

    def get_extension_by_number(extension_number)
      if !extension_number.is_a?(String)
        extension_number = extension_number.to_s
      end
      if @extensions_num2id.has_key?(extension_number)
        extension_id = @extensions_num2id[extension_number]
        if @extensions_hash.has_key?(extension_id)
          return @extensions_hash[extension_id]
        end
      end
      return nil
    end

    def get_department_members(department_id)
      if !department_id.is_a?(String)
        department_id = department_id.to_s
      end
      if department_id !~ /^[0-9]+$/
        raise 'department_id parameter must be a positive integer'
      end

      members = []

      res = @rc_api.client.get do |req|
        req.url "account/~/department/#{department_id}/members"
      end

      if res.body.has_key?('records')
        res.body['records'].each do |extension|
          if extension.has_key?('id')
            member = get_extension_by_id(extension['id'])
            if !member.nil?
              members.push member
            end
          end
        end
      end

      return members
    end

  end
end