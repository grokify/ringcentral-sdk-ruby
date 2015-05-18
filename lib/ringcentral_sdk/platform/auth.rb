require 'time'

module RingCentralSdk::Platform
  class Auth
    attr_accessor :data
    attr_accessor :remember

    attr_reader   :access_token
    attr_reader   :token_type

    def initialize()
      @data     = nil
      @remember = nil
    end
    def set_data(data={})
      return false unless data.is_a?(Hash)

      @access_token = data["access_token"] ? data["access_token"] : ''
      @expire_time  = data["expire_time"]  ? data["expire_time"]  : 0
      @token_type   = data["token_type"]   ? data["token_type"]   : ''

      @data = data
      return true
    end

    def is_access_token_valid()
      return _is_token_date_valid(@expire_time)
    end

    def _is_token_date_valid(token_date=nil)
      return false unless token_date.is_a?(Integer)
      return token_date > Time.now.to_i
    end

  end
end