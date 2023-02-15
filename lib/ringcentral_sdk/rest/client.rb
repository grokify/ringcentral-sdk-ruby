require 'base64'
require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware/oauth2_refresh'
require 'faraday_middleware-request-retry'
require 'multi_json'
require 'oauth2'

module RingCentralSdk
  module REST
    # Client is the RingCentral REST API client class which handles
    # HTTP requests with built-in OAuth handling
    class Client
      ACCESS_TOKEN_TTL  = 600 # 10 minutes
      REFRESH_TOKEN_TTL = 36_000 # 10 hours
      REFRESH_TOKEN_TTL_REMEMBER = 604_800 # 1 week
      ACCOUNT_PREFIX    = '/account/'.freeze
      ACCOUNT_ID        = '~'.freeze
      AUTHZ_ENDPOINT    = '/restapi/oauth/authorize'.freeze
      TOKEN_ENDPOINT    = '/restapi/oauth/token'.freeze
      REVOKE_ENDPOINT   = '/restapi/oauth/revoke'.freeze
      API_VERSION       = 'v1.0'.freeze
      URL_PREFIX        = '/restapi'.freeze
      DEFAULT_LANGUAGE  = 'en-us'.freeze

      attr_reader :config
      attr_reader :http
      attr_reader :logger
      attr_reader :oauth2client
      attr_reader :user_agent
      attr_reader :messages

      def initialize
        init_attributes

        raise ArgumentError, 'Config block not given' unless block_given?
        @config = RingCentralSdk::REST::Configuration.new
        yield config
        @config.inflate

        @oauth2client = new_oauth2_client

        unless @config.username.to_s.empty?
          authorize_password @config.username, @config.extension, @config.password
        end

        @messages = RingCentralSdk::REST::Messages.new self
      end

      def init_attributes
        @http = nil
        @user_agent = build_user_agent
      end

      def api_version_url
        @config.server_url + URL_PREFIX + '/' + API_VERSION
      end

      def create_url(url, add_server = false, add_method = nil, add_token = false)
        built_url = ''
        has_http = !url.index('http://').nil? && !url.index('https://').nil?

        built_url += @config.server_url if add_server && !has_http

        if url.index(URL_PREFIX).nil? && !has_http
          built_url += URL_PREFIX + '/' + API_VERSION + '/'
        end

        if url.index('/') == 0
          if built_url =~ %r{/$}
            built_url += url.gsub(%r{^/+}, '')
          else
            built_url += url
          end
        else # no /
          if built_url =~ %r{/$}
            built_url += url
          else
            built_url += '/' << url
          end
        end

        built_url
      end

      def create_urls(urls, add_server = false, add_method = nil, add_token = false)
        raise(ArgumentError, 'URLs is not an array') unless urls.is_a? Array
        built_urls = []
        urls.each do |url|
          built_urls.push(create_url(url, add_server, add_method, add_token))
        end
        built_urls
      end

      def authorize_url(opts = {})
        @oauth2client.auth_code.authorize_url(_add_redirect_uri(opts))
      end

      def authorize_code(code, params = {})
        token = @oauth2client.auth_code.get_token(code, _add_redirect_uri(params))
        set_token(token)
        token
      end

      def _add_redirect_uri(opts = {})
        if !opts.key?(:redirect_uri) && !@config.redirect_url.to_s.empty?
          opts[:redirect_uri] = @config.redirect_url.to_s
        end
        opts
      end

      def authorize_password(username, extension = '', password = '', params = {})
        token = @oauth2client.password.get_token(username, password, {
          extension: extension,
          headers: { 'Authorization' => 'Basic ' + api_key }
        }.merge(params))
        set_token token
        token
      end

      def token
        @http ? @http.builder.app.oauth2_token : nil
      end

      def set_token(token)
        if token.is_a? Hash
          token = OAuth2::AccessToken.from_hash(@oauth2client, token)
        end

        unless token.is_a? OAuth2::AccessToken
          raise 'Token is not a OAuth2::AccessToken'
        end

        @http = Faraday.new(url: api_version_url) do |conn|
          conn.request :oauth2_refresh, token
          conn.request :multipart
          conn.request :url_encoded
          conn.request :json
          conn.headers['User-Agent'] = @user_agent
          if @config.headers.is_a? Hash
            @config.headers.each do |k, v|
              conn.headers[k] = v
            end
          end
          conn.headers['RC-User-Agent'] = @user_agent
          conn.headers['SDK-User-Agent'] = @user_agent
          conn.response :json, content_type: /\bjson$/
          conn.response :logger, @config.logger
          if @config.retry
            conn.use FaradayMiddleware::Request::Retry, @config.retry_options
          end
          conn.adapter Faraday.default_adapter
        end

        token_string = MultiJson.encode token.to_hash
        @config.logger.info("SET_TOKEN: #{token_string}")
      end

      def new_oauth2_client
        OAuth2::Client.new(
          @config.app_key,
          @config.app_secret,
          site: @config.server_url,
          authorize_url: @config.authorize_url,
          token_url: TOKEN_ENDPOINT
        )
      end

      def set_oauth2_client(client = nil)
        if client.nil?
          @oauth2client = new_oauth2_client
        elsif client.is_a? OAuth2::Client
          @oauth2client = client
        else
          raise ArgumentError, 'client is not an OAuth2::Client'
        end
      end

      def api_key
        Base64.encode64("#{@config.app_key}:#{@config.app_secret}").gsub(/\s/, '')
      end

      def send_request(request_sdk = {})
        if request_sdk.is_a? Hash
          request_sdk = RingCentralSdk::REST::Request::Simple.new request_sdk
        elsif !request_sdk.is_a? RingCentralSdk::REST::Request::Base
          raise ArgumentError, 'Request is not a RingCentralSdk::REST::Request::Base'
        end

        method = request_sdk.method.to_s.downcase
        method = 'get' if method.empty?

        res = nil

        case method
        when 'delete'
          res = @http.delete { |req| req = inflate_request(req, request_sdk) }
        when 'get'
          res = @http.get { |req| req = inflate_request(req, request_sdk) }
        when 'post'
          res = @http.post { |req| req = inflate_request(req, request_sdk) }
        when 'put'
          res = @http.put { |req| req = inflate_request(req, request_sdk) }
        else
          raise "method [#{method}] not supported"
        end

        res
      end

      def inflate_request(req_faraday, req_sdk)
        req_faraday.url req_sdk.url
        req_faraday.body = req_sdk.body if req_sdk.body
        if req_sdk.params.is_a? Hash
          req_sdk.params.each { |k, v| req_faraday.params[k] = v }
        end
        if req_sdk.headers.is_a? Hash
          req_sdk.headers.each { |k, v| req_faraday.headers[k] = v }
        end

        ct = req_sdk.content_type
        if !ct.nil? && !ct.to_s.strip.empty?
          req_faraday.headers['Content-Type'] = ct.to_s
        end
        req_faraday
      end

      def build_user_agent
        ua = "ringcentral-sdk-ruby/#{RingCentralSdk::VERSION} %s/%s %s" % [
          (RUBY_ENGINE rescue nil || 'ruby'),
          RUBY_VERSION,
          RUBY_PLATFORM
        ]
        ua.strip
      end

      def create_subscription
        RingCentralSdk::REST::Subscription.new self
      end

      alias authorize authorize_password
      alias login authorize_password
      private :api_version_url
    end
  end
end
