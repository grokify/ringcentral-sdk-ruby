require 'dotenv'

module RingCentralSdk::REST
  class Config
    attr_accessor :user
    attr_accessor :app
    attr_accessor :env

    def load_dotenv
      Dotenv.load
      load_env_app()
      load_env_user()
      load_env_rc()
      return self
    end

    def load_env_app
      ['RC_APP_KEY', 'RC_APP_SECRET', 'RC_APP_SERVER_URL'].each do |var|
        if !ENV.key?(var)
          fail "environment variable '#{var}' not found"
        end
      end

      @app = RingCentralSdk::REST::ConfigApp.new
      @app.key = ENV['RC_APP_KEY']
      @app.secret = ENV['RC_APP_SECRET']
      @app.server_url = ENV['RC_APP_SERVER_URL']
    end

    def load_env_user
      ['RC_USER_USERNAME', 'RC_USER_PASSWORD'].each do |var|
        if !ENV.key?(var)
          fail "environment variable '#{var}' not found"
        end
      end

      @user = RingCentralSdk::REST::ConfigUser.new
      @user.username = ENV['RC_USER_USERNAME']
      @user.extension = ENV['RC_USER_EXTENSION']
      @user.password = ENV['RC_USER_PASSWORD']
    end

    def load_env_rc
      @env = RingCentralSdk::REST::ConfigEnvRc.new
    end
  end
end

module RingCentralSdk::REST
  class ConfigUser
    attr_accessor :username
    attr_accessor :extension
    attr_accessor :password
  end
end

module RingCentralSdk::REST
  class ConfigApp
    attr_accessor :key
    attr_accessor :secret
    attr_accessor :server_url
  end
end

module RingCentralSdk::REST
  class ConfigEnvRc
    attr_accessor :data
    def initialize
      @data = {}
      ENV.each do |k,v|
        next unless k.index('RC_') == 0
        @data[k] = v
      end
    end
  end
end
