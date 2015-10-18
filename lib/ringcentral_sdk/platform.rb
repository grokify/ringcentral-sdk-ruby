require 'base64'
require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware/oauth2_refresh'
require 'oauth2'

module RingCentralSdk
  class Platform

    ACCESS_TOKEN_TTL  = 600             # 10 minutes
    REFRESH_TOKEN_TTL = 36000           # 10 hours
    REFRESH_TOKEN_TTL_REMEMBER = 604800 # 1 week
    ACCOUNT_PREFIX    = '/account/'
    ACCOUNT_ID        = '~'
    AUTHZ_ENDPOINT    = '/restapi/oauth/authorize'
    TOKEN_ENDPOINT    = '/restapi/oauth/token'
    REVOKE_ENDPOINT   = '/restapi/oauth/revoke'
    API_VERSION       = 'v1.0'
    URL_PREFIX        = '/restapi'

    attr_accessor :server_url

    attr_reader   :client
    attr_reader   :oauth2client
    attr_reader   :token
    attr_reader   :user_agent
    attr_reader   :redirect_uri

    def initialize(app_key, app_secret, server_url=RingCentralSdk::RC_SERVER_SANDBOX, opts={})
      @app_key      = app_key.to_s
      @app_secret   = app_secret.to_s
      @server_url   = server_url
      @token        = nil
      @client       = nil
      @redirect_uri = ''
      @user_agent   = get_user_agent()
      @oauth2client = new_oauth2_client()
      if opts.is_a?(Hash)
        @redirect_uri = opts.has_key?(:redirect_uri) ? opts[:redirect_uri] : ''
        if opts.has_key?(:username) && opts.has_key?(:password)
          extension = opts.has_key?(:extension) ? opts[:extension] : ''
          authorize_password(opts[:username], extension, opts[:password])
        end
      end
    end

    def get_api_version_url()
      return @server_url + URL_PREFIX + '/' + API_VERSION 
    end

    def create_url(url, add_server=false, add_method=nil, add_token=false)
      built_url = ''
      has_http = !url.index('http://').nil? && !url.index('https://').nil?

      if add_server && ! has_http
        built_url += @server_url
      end

      if url.index(URL_PREFIX).nil? && ! has_http
        built_url += URL_PREFIX + '/' + API_VERSION + '/'
      end

      if url.index('/') == 0
        if built_url =~ /\/$/
          built_url += url.gsub(/^\//, '')
        else
          built_url += url
        end
      else # no /
        if built_url =~ /\/$/
          built_url += url
        else
          built_url += '/' + url
        end
      end

      return built_url
    end

    def create_urls(urls, add_server=false, add_method=nil, add_token=false)
      unless urls.is_a?(Array)
        raise "URLs is not an array"
      end
      built_urls = []
      urls.each do |url|
        built_urls.push(create_url(url, add_server, add_method, add_token))
      end
      return built_urls
    end

    def authorize_url(opts={})
      if ! opts.has_key?(:redirect_uri) && @redirect_uri.to_s.length>0
        opts[:redirect_uri] = @redirect_uri.to_s
      end
      @oauth2client.auth_code.authorize_url(opts)
    end

    def authorize_code(code, opts={})
      if ! opts.has_key?(:redirect_uri) && @redirect_uri.to_s.length>0
        opts[:redirect_uri] = @redirect_uri.to_s
      end
      token = @oauth2client.auth_code.get_token(code, opts)
      set_token(token)
      return token
    end

    def authorize_password(username, extension='', password='', remember=false)
      token = @oauth2client.password.get_token(username, password, {
        :extension => extension,
        :headers   => { 'Authorization' => 'Basic ' + get_api_key() } })
      set_token(token)
      return token
    end

    def set_token(token)
      if token.is_a?(Hash)
        token = OAuth2::AccessToken::from_hash(@oauth2client, token)
      end

      unless token.is_a?(OAuth2::AccessToken)
        raise "Token is not a OAuth2::AccessToken"
      end

      @token  = token

      @client = Faraday.new(:url => get_api_version_url()) do |conn|
        conn.request  :oauth2_refresh, @token
        conn.request  :json
        conn.request  :url_encoded
        conn.headers['User-Agent'] = @user_agent
        conn.headers['Rc-User-Agent'] = @user_agent
        conn.response :json, :content_type => 'application/json'
        conn.adapter  Faraday.default_adapter
      end
    end

    def new_oauth2_client()
      return OAuth2::Client.new(@app_key, @app_secret,
        :site          => @server_url,
        :authorize_url => AUTHZ_ENDPOINT,
        :token_url     => TOKEN_ENDPOINT)
    end

    def set_oauth2_client(client=nil)
      if client.nil?
        @oauth2client = new_oauth2_client()
      elsif client.is_a?(OAuth2::Client)
        @oauth2client = client
      else
        raise "client is not an OAuth2::Client"
      end
    end

    def get_api_key()
      api_key = (@app_key.is_a?(String) && @app_secret.is_a?(String)) \
        ? Base64.encode64("#{@app_key}:#{@app_secret}").gsub(/[\s\t\r\n]/,'') : ''
      return api_key
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

    def get_user_agent()
      ua = "ringcentral-sdk-ruby/#{RingCentralSdk::VERSION} %s/%s %s" % [
        (RUBY_ENGINE rescue nil or "ruby"),
        RUBY_VERSION,
        RUBY_PLATFORM
      ]
      return ua.strip
    end

    def create_subscription()
      return RingCentralSdk::Subscription.new(self)
    end

    alias_method :authorize, :authorize_password
    alias_method :login, :authorize_password
    private :get_api_version_url
  end
end
