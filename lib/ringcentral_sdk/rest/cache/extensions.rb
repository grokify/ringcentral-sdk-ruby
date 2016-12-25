require 'time'
require 'uri'

module RingCentralSdk::REST::Cache
  class Extensions
    attr_accessor :client
    attr_accessor :account_id
    attr_reader :extensions_hash
    attr_reader :extensions_num2id
    attr_reader :last_retrieved

    def initialize(client)
      @client = client
      @account_id = '~'
      flush
    end

    def flush
      @extensions_hash = {}
      @extensions_num2id = {}
      @last_retrieved = -1
    end

    def retrieve(params={}, retrieve_all=true)
      @last_retrieved = Time.now.to_i
      uri = URI.parse "account/#{@account_id}/extension"
      if params.length > 0
        uri.query = URI.encode_www_form params
      end
      res = @client.http.get do |req|
        req.url uri.to_s
        if retrieve_all
          req.params['page'] = 1
          req.params['perPage'] = 1000
        end
      end
      res.body['records'].each do |extension|
        if extension.key?('id') && extension['id'] > 0
          @extensions_hash[extension['id'].to_s] = extension
        end
      end
      if retrieve_all
        while res.body.key?('navigation') && res.body['navigation'].key?('nextPage')
          res = @client.http.get do |req|
            req.url res.body['navigation']['nextPage']['uri']
          end
          res.body['records'].each do |extension|
            if extension.key?('id') && extension['id'] > 0
              @extensions_hash[extension['id'].to_s] = extension
            end
          end
        end
      end
      inflate_num2id()
      return @extensions_hash
    end

    def retrieve_all()
      retrieve({}, true)
    end

    def inflate_num2id()
      num2id = {}
      @extensions_hash.each do |k,v|
        if v.key?('id') && v['id'] > 0 &&
          v.key?('extensionNumber') && v['extensionNumber'].length>0
          num2id[v['extensionNumber']] = v['id'].to_s
        end
      end
      @extensions_num2id = num2id
      return num2id
    end

    def get_extension_by_id(extension_id)
      unless extension_id.is_a? String
        extension_id = extension_id.to_s
      end
      if @extensions_hash.key? extension_id
          return @extensions_hash[extension_id]
      end
      return nil
    end

    def get_extension_by_number(extension_number)
      unless extension_number.is_a? String
        extension_number = extension_number.to_s
      end
      if @extensions_num2id.key?(extension_number)
        extension_id = @extensions_num2id[extension_number]
        if @extensions_hash.key?(extension_id)
          return @extensions_hash[extension_id]
        end
      end
      return nil
    end

    def get_department_members(department_id)
      unless department_id.is_a? String
        department_id = department_id.to_s
      end
      if department_id !~ /^[0-9]+$/
        raise 'department_id parameter must be a positive integer'
      end

      members = []

      res = @client.http.get do |req|
        req.url "account/#{account_id}/department/#{department_id}/members"
      end

      if res.body.key? 'records'
        res.body['records'].each do |extension|
          if extension.key? 'id'
            member = get_extension_by_id extension['id']
            members.push member unless member.nil?
          end
        end
      end

      return members
    end
  end
end
