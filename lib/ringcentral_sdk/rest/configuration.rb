require 'dotenv'
require 'logger'
require 'multi_json'

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
      attr_accessor :logger

      def inflate
        @rc_env = {}
        @logger = default_logger unless @logger    
        load_environment if load_env
        load_token
      end

      def default_logger
        logger = Logger.new STDOUT
        logger.level = Logger::WARN
        logger
      end

      def load_environment
        return unless env
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
      end

      def load_token
        if (@token.nil? || @token.empty?) && !@token_file.empty?
          @token = IO.read @token_file if File.exist? @token_file
        end

        @token = MultiJson.decode(token) if @token.to_s =~ /^\s*{/
      end
    end
  end
end
