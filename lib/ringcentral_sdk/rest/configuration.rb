require 'dotenv'
require 'fiddle'
require 'logger'
require 'multi_json'
require 'ringcentral_sdk'
require 'uri'

module RingCentralSdk
  module REST
    # Configuration class populated by Client constructor block
    class Configuration
      attr_accessor :server_url
      attr_accessor :app_key
      attr_accessor :app_secret
      attr_accessor :redirect_url

      attr_accessor :username
      attr_accessor :extension
      attr_accessor :password
      attr_accessor :token
      attr_accessor :token_file

      attr_accessor :load_env
      attr_accessor :headers
      attr_accessor :retry
      attr_accessor :retry_options
      attr_accessor :logger

      def inflate
        @logger = default_logger if !defined?(@logger) || @logger.nil?
        load_environment if load_env
        inflate_headers
        inflate_retry
        inflate_retry_options
        inflate_token
      end

      def default_logger
        logger = Logger.new STDOUT
        logger.level = Logger::WARN
        logger
      end

      def load_environment
        Dotenv.load
        @server_url = ENV['RC_SERVER_URL'] if ENV.key? 'RC_SERVER_URL'
        @app_key = ENV['RC_APP_KEY'] if ENV.key? 'RC_APP_KEY'
        @app_secret = ENV['RC_APP_SECRET'] if ENV.key? 'RC_APP_SECRET'
        @redirect_url = ENV['RC_APP_REDIRECT_URL'] if ENV.key? 'RC_APP_REDIRECT_URL'
        @username = ENV['RC_USER_USERNAME'] if ENV.key? 'RC_USER_USERNAME'
        @extension = ENV['RC_USER_EXTENSION'] if ENV.key? 'RC_USER_EXTENSION'
        @password = ENV['RC_USER_PASSWORD'] if ENV.key? 'RC_USER_PASSWORD'
        @token = ENV['RC_TOKEN'] if ENV.key? 'RC_TOKEN'
        @token_file = ENV['RC_TOKEN_FILE'] if ENV.key? 'RC_TOKEN_FILE'
        @retry = ENV['RC_RETRY'] if ENV.key? 'RC_RETRY'
        @retry_options = ENV['RC_RETRY_OPTIONS'] if ENV.key? 'RC_RETRY_OPTIONS'
        @headers = ENV['RC_HEADERS'] if ENV.key? 'RC_HEADERS'
      end

      def inflate_retry
        if !defined?(@retry) || @retry.nil?
          @retry = false
        elsif @retry.is_a? String
          @retry = @retry.to_s.strip.downcase == 'true' ? true : false
        elsif ![true, false].include? @retry
          @retry = @retry ? true : false
        end
      end

      def inflate_retry_options
        if @retry == false
          @retry_options = {}
          return
        end
        if !@retry_options.nil? && @retry_options.to_s =~ /^\s*{/
          @retry_options = MultiJson.decode @retry_options.to_s, symbolize_keys: true
        else
          @retry_options = {}
        end
        @retry_options[:error_codes] = [429, 503, 504] unless @retry_options.key? :error_codes
        @retry_options[:logger] = @logger
      end

      def inflate_headers
        @headers = {} unless defined? @headers
        if !@headers.nil? && @headers.is_a?(String) && @headers =~ /^\s*{/
          @headers = MultiJson.decode @headers, symbolize_keys: true
        end
      end

      def inflate_token
        @token = nil unless defined? @token

        if (@token.nil? || @token.empty?) && !token_file.nil? && !@token_file.empty?
          @token = IO.read @token_file if File.exist? @token_file
        end

        if !defined?(@token) && !@token.nil? && @token.is_a?(String) && @token =~ /^\s*{/
          @token = MultiJson.decode @token
        end
      end

      def authorize_url
        puts @server_url
        puts RingCentralSdk::REST::Client::AUTHZ_ENDPOINT
        URI.join(@server_url, RingCentralSdk::REST::Client::AUTHZ_ENDPOINT)
      end
    end
  end
end
