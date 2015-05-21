require 'base64'
require 'faraday'
require 'faraday_middleware'

module RingCentralSdk::Platform
  class Platform

    ACCESS_TOKEN_TTL  = 600             # 10 minutes
    REFRESH_TOKEN_TTL = 36000           # 10 hours
    REFRESH_TOKEN_TTL_REMEMBER = 604800 # 1 week
    ACCOUNT_PREFIX    = '/account/'
    ACCOUNT_ID        = '~'
    TOKEN_ENDPOINT    = '/restapi/oauth/token'
    REVOKE_ENDPOINT   = '/restapi/oauth/revoke'
    API_VERSION       = 'v1.0'
    URL_PREFIX        = '/restapi'

    attr_reader :client

    def initialize(app_key='',app_secret='',server_url='https://platform.devtest.ringcentral.com')

      @app_key    = app_key
      @app_secret = app_secret
      @server_url = server_url
      @_auth       = RingCentralSdk::Platform::Auth.new

      @client     = Faraday.new(:url => get_api_version_url()) do |conn|
        conn.request  :json
        conn.request  :url_encoded
        conn.response :json, :content_type => 'application/json'
        conn.adapter  Faraday.default_adapter
      end

    end

    def get_api_version_url()
      return @server_url + URL_PREFIX + '/' + API_VERSION 
    end

    def authorize(username='',extension='',password='',remember=false)

      response = _auth_call({}, {
        :grant_type        => 'password',
        :username          => username,
        :extension         => extension.is_a?(String) || extension.is_a?(Integer) ? extension : '',
        :password          => password,
        :access_token_ttl  => ACCESS_TOKEN_TTL,
        :refresh_token_ttl => remember ? REFRESH_TOKEN_TTL_REMEMBER : REFRESH_TOKEN_TTL
      })

      @_auth.set_data( response.body )
      @_auth.remember = remember

      if response.body.is_a?(Hash)
        if response.body.has_key?("access_token") && response.body["access_token"].is_a?(String)
          @client.headers['Authorization'] = 'Bearer ' + response.body["access_token"]
        end
      end

      return response
    end

    def get_api_key()
      api_key = (@app_key.is_a?(String) && @app_secret.is_a?(String)) \
        ? Base64.encode64(@app_key + ":" + @app_secret).gsub(/[\s\r\n]/,"") : ''
      return api_key
    end

    def get_auth_header()
      if @_auth.token_type.is_a?(String) && @_auth.access_token.is_a?(String)
        return @_auth.token_type + ' ' + @_auth.access_token
      end
      return ''
    end

    def _auth_call(queryParams={},body={})
      return @client.post do |req|
        req.url TOKEN_ENDPOINT
        req.headers['Authorization'] = 'Basic ' + get_api_key()
        req.headers['Content-Type']  = 'application/x-www-form-urlencoded;charset=UTF-8'
        if body.is_a?(Hash) && body.size > 0
          req.body = body
        end
      end
    end

    def request(helper=nil)
      unless helper.is_a?(RingCentralSdk::Helpers::Request)
        raise 'Request is not a RingCentralSdk::Helpers::Request'
      end

      if helper.method.downcase == 'post'
        resp       =  @client.post do |req|
          req.url helper.url
          req.headers['Content-Type'] = helper.content_type if helper.content_type
          req.body = helper.body if helper.body
        end
        return resp
      end
      return nil
    end
    
    private :_auth_call, :get_api_key, :get_api_version_url, :get_auth_header
  end
end
