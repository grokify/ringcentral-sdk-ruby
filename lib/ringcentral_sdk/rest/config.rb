require 'dotenv'

module RingCentralSdk::REST
  class Config
    attr_accessor :user
    attr_accessor :app
    attr_accessor :env

    def initialize
      @app = RingCentralSdk::REST::ConfigApp.new
      @user = RingCentralSdk::REST::ConfigUser.new
      @env = RingCentralSdk::REST::ConfigEnvRc.new
    end

    def load_dotenv
      Dotenv.load
      @app.load_env()
      @user.load_env()
      @env.load_env()
      return self
    end
  end
end

module RingCentralSdk::REST
  class ConfigUser
    attr_accessor :username
    attr_accessor :extension
    attr_accessor :password

    def load_env
      @username = ENV['RC_USER_USERNAME']
      @extension = ENV['RC_USER_EXTENSION']
      @password = ENV['RC_USER_PASSWORD']
    end

    def nilify
      @username = ''
      @extension = ''
      @password = ''
    end
  end
end

module RingCentralSdk::REST
  class ConfigApp
    attr_accessor :key
    attr_accessor :secret
    attr_accessor :server_url
    attr_accessor :redirect_url

    def initialize(app_key='', app_secret='', server_url=RingCentralSdk::RC_SERVER_SANDBOX, opts={})
      @key = app_key
      @secret = app_secret
      @server_url = server_url
      if opts.key?(:redirect_url)
        @redirect_url = opts[:redirect_url]
      elsif opts.key?(:redirect_uri)
        @redirect_url = opts[:redirect_uri]
      else
        @redirect_url = ''
      end
    end

    def load_env
      ['RC_APP_KEY', 'RC_APP_SECRET', 'RC_APP_SERVER_URL', 'RC_APP_REDIRECT_URL'].each do |var|
        if !ENV.key?(var)
          fail "environment variable '#{var}' not found"
        end
      end
      
      @key = ENV['RC_APP_KEY']
      @secret = ENV['RC_APP_SECRET']
      @server_url = ENV['RC_APP_SERVER_URL']
      @redirect_url = ENV['RC_APP_REDIRECT_URL']
    end

    def to_hash
      {
        key: @key,
        secret: @secret,
        server_url: @server_url,
        redirect_url: @redirect_url
      }
    end
  end
end

module RingCentralSdk::REST
  class ConfigEnvRc
    attr_accessor :data
    def initialize
      @data = {}
    end
    def load_env
      ENV.each do |k,v|
        next unless k.index('RC_') == 0
        @data[k] = v
      end
    end
  end
end
