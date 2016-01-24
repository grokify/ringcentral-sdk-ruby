require 'base64'
require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware/oauth2_refresh'
require 'oauth2'

module RingCentralSdk::REST
  class Client

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

    attr_reader :app_config
    attr_reader :http
    attr_reader :oauth2client
    attr_reader :token
    attr_reader :user_agent
    attr_reader :messages

    def initialize(app_key='', app_secret='', server_url=RingCentralSdk::RC_SERVER_SANDBOX, opts={})
      init_attributes()
      app_config = RingCentralSdk::REST::ConfigApp.new(app_key, app_secret, server_url, opts)
      app_config(app_config)

      if opts.key?(:username) && opts.key?(:password)
        extension = opts.key?(:extension) ? opts[:extension] : ''
        authorize_password(opts[:username], extension, opts[:password])
      end

      @messages = RingCentralSdk::REST::Messages.new(self)
    end

    def app_config(app_config)
      @app_config = app_config
      @oauth2client = new_oauth2_client()
    end

    def init_attributes()
      @token = nil
      @http = nil
      @user_agent = get_user_agent()
    end

    def api_version_url()
      return @app_config.server_url + URL_PREFIX + '/' + API_VERSION 
    end

    def create_url(url, add_server=false, add_method=nil, add_token=false)
      built_url = ''
      has_http = !url.index('http://').nil? && !url.index('https://').nil?

      if add_server && ! has_http
        built_url += @app_config.server_url
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
      @oauth2client.auth_code.authorize_url(_add_redirect_uri(opts))
    end

    def authorize_code(code, opts={})
      token = @oauth2client.auth_code.get_token(code, _add_redirect_uri(opts))
      set_token(token)
      return token
    end

    def _add_redirect_uri(opts={})
      if !opts.key?(:redirect_uri) && @app_config.redirect_url.to_s.length > 0
        opts[:redirect_uri] = @app_config.redirect_url.to_s
      end
      return opts
    end

    def authorize_password(username, extension='', password='', remember=false)
      token = @oauth2client.password.get_token(username, password, {
        :extension => extension,
        :headers   => { 'Authorization' => 'Basic ' + get_api_key() } })
      set_token(token)
      return token
    end

    def authorize_user(user, remember=false)
      authorize_password(user.username, user.extension, user.password)
    end

    def set_token(token)
      if token.is_a?(Hash)
        token = OAuth2::AccessToken::from_hash(@oauth2client, token)
      end

      unless token.is_a?(OAuth2::AccessToken)
        raise "Token is not a OAuth2::AccessToken"
      end

      @token = token

      @http = Faraday.new(:url => api_version_url()) do |conn|
        conn.request  :oauth2_refresh, @token
        conn.request  :json
        conn.request  :url_encoded
        conn.headers['User-Agent'] = @user_agent
        conn.headers['Rc-User-Agent'] = @user_agent
        conn.response :json, :content_type => /\bjson$/
        conn.adapter  Faraday.default_adapter
      end
    end

    def new_oauth2_client()
      return OAuth2::Client.new(@app_config.key, @app_config.secret,
        :site          => @app_config.server_url,
        :authorize_url => AUTHZ_ENDPOINT,
        :token_url     => TOKEN_ENDPOINT)
    end

    def set_oauth2_client(client=nil)
      if client.nil?
        @oauth2client = new_oauth2_client()
      elsif client.is_a?(OAuth2::Client)
        @oauth2client = client
      else
        fail "client is not an OAuth2::Client"
      end
    end

    def get_api_key()
      api_key = (@app_config.key.is_a?(String) && @app_config.secret.is_a?(String)) \
        ? Base64.encode64("#{@app_config.key}:#{@app_config.secret}").gsub(/[\s\t\r\n]/,'') : ''
      return api_key
    end

    def send_request(request=nil)
      unless request.is_a?(RingCentralSdk::REST::Request::Base)
        fail 'Request is not a RingCentralSdk::REST::Request::Base'
      end

      if request.method.downcase == 'post'
        resp       =  @http.post do |req|
          req.url request.url
          req.headers['Content-Type'] = request.content_type if request.content_type
          req.body = request.body if request.body
        end
        return resp
      end
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
      return RingCentralSdk::REST::Subscription.new(self)
    end

    alias_method :authorize, :authorize_password
    alias_method :login, :authorize_password
    private :api_version_url
  end
end
