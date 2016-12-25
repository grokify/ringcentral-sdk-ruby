require 'dotenv'
require 'logger'
require 'multi_json'

module RingCentralSdk
  module REST
    # Configuration class populated by Client constructor block
    class Configuration
      attr_accessor :dotenv

      attr_accessor :app_key
      attr_accessor :app_secret
      attr_accessor :server_url
      attr_accessor :redirect_url

      attr_accessor :username
      attr_accessor :extension
      attr_accessor :password
      attr_accessor :token
      attr_accessor :token_file

      attr_accessor :headers
      attr_accessor :retry
      attr_accessor :logger

      attr_accessor :env

      def inflate
        @env = {}
        set_default_logger
        load_dotenv
      end

      def set_default_logger
        return if defined? @logger
        @logger = Logger.new STDOUT
        @logger.level = Logger::WARN
      end

      def load_dotenv
        return unless dotenv
        Dotenv.load
        @app_key = ENV['RC_APP_KEY']
        @app_secret = ENV['RC_APP_SECRET']
        @server_url = ENV['RC_APP_SERVER_URL']
        @redirect_url = ENV['RC_APP_REDIRECT_URL']

        @username = ENV['RC_USER_USERNAME']
        @extension = ENV['RC_USER_EXTENSION']
        @password = ENV['RC_USER_PASSWORD']

        load_dotenv_token
        load_dotenv_rc
      end

      def load_dotenv_token
        token = ENV['RC_TOKEN']
        if token.to_s.empty?
          token_file = ENV['RC_TOKEN_FILE']
          if token_file.to_s.length > 0 && File.exist?(token_file)
            token = IO.read token_file
          end
        end

        if token.to_s =~ /^\s*{/
          @token = MultiJson.decode token
        end
      end

      def load_dotenv_rc
        ENV.each do |k, v|
          next unless k.index('RC_') == 0
          @env[k] = v
        end
      end
    end
  end
end
